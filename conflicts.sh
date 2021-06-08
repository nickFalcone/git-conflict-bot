#!/bin/bash

# A script to notify a Slack channel about git conflicts

# TODO: modify repo_path to match the repository you are checking
repo_path=~/projects/conflicted-repo/

while getopts ":d:i:" opt; do
  case $opt in
    d)
      dest_branch=$OPTARG >&2
      ;;
		i)
      incoming_branch=$OPTARG >&2
      ;;
  esac
done

# Exit if either branch argument is missing.
if [ -z "$dest_branch" ] || [ -z "$incoming_branch" ]; then
	printf 'Provide an incoming and destination branch. Eg:\n\n ./conflicts.sh -i development -d main\n\n' >&2
	exit 1
fi

# Assign Slack webhook URL from git ignored file to keep it private.
slack_endpoint=$(<endpoint.txt)

cd $repo_path

# Exit if target repository working tree is not clean.
# We won't be able to perform the local merge.
if [[ $(git diff --stat) != '' ]]; then
  printf "Please resolve working tree in $repo_path before continuing.\n"
	exit 1
fi

# Generate conflicts (if any) locally.
git fetch && git checkout $dest_branch && git pull && git pull origin $incoming_branch

# Build up list of conflicted files.
files=($(git diff --name-only --diff-filter=U))

files_list=""

for file in "${files[@]}"; do
	files_list+="\`$file\`\n"
done

# Create payload for Slack webhook.
if [[ ${#files[@]} -eq 0 ]]; then
	message="No conflicts from the \`$incoming_branch\` branch to the \`$dest_branch\` branch :tada:"
else
	message="The following file(s) from the \`$incoming_branch\` branch to the \`$dest_branch\` branch are conflicted:\n$files_list"
fi

payload=$(
	cat <<EOF
{
  "text": "$message"
}
EOF
)

# POST to Slack webhook URL. Re-attempt up to 10 times if failed.
curl --connect-timeout 10 --retry 10 --retry-max-time 600 -i -X POST -H 'Content-type: application/json' -d "$payload" "$slack_endpoint"

# Reset the target repository after the attempted local merge.
# It should be a safe action since any prior saved but not
# committed work in the repository would trigger the script to exit
# before reaching this point. 
git reset --hard HEAD && git clean -fd
