# Git conflict Slack bot 🤖

Notify a Slack channel about git merge conflicts. This could be helpful to run automatically on long-lived development branches.

## Install

Clone the repository and make the script executable:

```bash
git clone git@github.com:nickFalcone/git-conflict-bot.git
cd git-conflict-bot/
chmod +x conflicts.sh
```

## Set up Slack

Set up a Slack account and [create a new app](https://api.slack.com/apps/new) __from scratch__.

Configure the __name__ and __workspace__, then Create App.

![new](images/new.jpg)

Select __incoming webhooks__

![incoming webhooks](https://a.slack-edge.com/80588/img/api/articles/hw_add_incoming_webhook.png)

Be sure to activate incoming webhooks
![activate](images/activate.jpg)

Click __Add New Webhook to Workspace__

![add new webhook](images/new-hook.jpg)

Confirm the bot name and the Slack channel the bot will post in. Then click __Allow__.

![allow](images/auth.jpg)

Copy the newly created Webhook URL to clipboard. Do not add it to files that will be tracked by git.

![copy webhook](images/webhook-url.jpg)

## Endpoint

Create the `endpoint.txt` file with the following command using your copied Webhook URL. This file will not be tracked by git.

```bash
echo -e "https://hooks.slack.com/services/your/hook/here" >> endpoint.txt
```

## Set repository path

Modify the `repo_path` variable to match the repository you want to check.

```bash
repo_path=~/projects/conflicted-repo/
```

## Run

```bash
./conflicts.sh -i development -d main
```
`-i` incoming branch, required
`-d` destination branch, required

## Results

The bot will report any conflicted files from the merge.

![report](images/report.jpg)

## Automate

The script can run at scheduled intervals with [crontab](https://man7.org/linux/man-pages/man5/crontab.5.html) or [Mac Automator](https://support.apple.com/en-gb/guide/automator/autbbd4cc11c/mac).
