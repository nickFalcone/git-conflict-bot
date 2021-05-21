# Git Conflict Bot

Preamble

## Install

Clone the repository and create an `endpoint.txt` file to hold your Slack webhook URL:

```bash
git clone git@github.com:nickFalcone/git-conflict-bot.git
cd git-conflict-bot/
chmod +x conflicts.sh
echo -e "<your Slack webhook URL>" >> endpoint.txt
```

## Run

```bash
./conflicts.sh
```