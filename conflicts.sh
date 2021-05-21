#!/bin/bash

# A script to notify a Slack channel about git conflicts

# TODO: read these in prompt or as argument?
repo_path=~/projects/conflicted-repo/
dest_branch=master
incoming_branch=conflicts
slack_endpoint=$(<endpoint.txt) # paste Slack webhook URL into `endpoint.txt` to keep private

cd $repo_path

git reset --hard HEAD && git clean -fd
git fetch && git checkout $dest_branch && git pull && git pull origin $incoming_branch

files=($(git diff --name-only --diff-filter=U))

file_table="| File |\n| ------ |\n"

for file in "${files[@]}"; do
  file_table+="| $file |\n"
done

if [ ${#files[@]} -eq 0 ]; then
  message="No conflicts from $dest_branch to $incoming_branch :tada:"
else
  message="The following file(s) from $dest_branch to $incoming_branch are conflicted:\n$file_table"
fi

# TODO: formatting on Slack looks like garbage
payload=$(cat <<EOF
{
  "text": "The following files from $dest_branch to $incoming_branch are conflicted:\n$file_table"
}
EOF
)

# POST to Slack webhook URL. Re-attempt up to 10 times if failed. 
curl --connect-timeout 10 --retry 10 --retry-max-time 600 -i -X POST -H 'Content-type: application/json' -d "$payload" "$slack_endpoint"

# Bring repo back to HEAD
git reset --hard HEAD && git clean -fd
