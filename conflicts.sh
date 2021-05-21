#!/bin/bash

# A script to notify a Slack channel about git conflicts

dest_branch=master
incoming_branch=conflicts

slack_endpoint=$(<endpoint.txt) # paste Slack webhook URL into `endpoint.txt` to keep private
echo $slack_endpoint

cd ~/projects/conflicted-repo/

git reset --hard HEAD && git clean -fd
git fetch && git checkout $dest_branch && git pull && git pull origin $incoming_branch

files=($(git diff --name-only --diff-filter=U))

file_table="| File |\n| ------ |\n"

for file in "${files[@]}"; do
  file_table+="| $file |\n"
done


payload=$(cat <<EOF
{
  "text": "The following files from $dest_branch to $incoming_branch are conflicted:\n$file_table"
}
EOF
)

curl --connect-timeout 10 --retry 10 --retry-max-time 600 -i -X POST -H 'Content-type: application/json' -d "$payload" "$slack_endpoint"

git reset --hard HEAD && git clean -fd
