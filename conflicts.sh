#!/bin/bash

# A script to notify a Slack channel about git conflicts

# TODO: read these in prompt or as argument?
repo_path=~/projects/conflicted-repo/
dest_branch=master
incoming_branch=conflicts

# Assign Slack webhook URL from git ignored file to keep it private
slack_endpoint=$(<endpoint.txt)

cd $repo_path

# Generate conflicts locally
git fetch && git checkout $dest_branch && git pull && git pull origin $incoming_branch

# Build up list of conflicted files and create payload for Slack webhook
files=($(git diff --name-only --diff-filter=U))

files_list=""

for file in "${files[@]}"; do
	files_list+="\`$file\`\n"
done

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
