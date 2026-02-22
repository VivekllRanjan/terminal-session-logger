# 🖥️ terminal-session-logger

Automatically logs every terminal session to a clean, readable text file. No manual steps — just open a terminal, work, close it.

## Files
```
├── cleanlog.py       # Strips ANSI/VT100 escape codes from raw recordings
├── setup_autolog.sh  # One-time installer
└── README.md
```

## Installation
```bash
git clone https://github.com/yourusername/terminal-session-logger.git
cd terminal-session-logger
chmod +x setup_autolog.sh
./setup_autolog.sh
```
Then open a new terminal. Done.

## Log Output
Saved to `$HOME/Desktop/sessions/22Feb_19:30.log`
```
$ pwd
/home/vivek
$ git status
On branch main
nothing to commit, working tree clean
```

## How It Works
Uses `script(1)` to record the session to `/tmp`, then `cleanlog.py` strips all escape sequences on close. Since clicking **X** sends SIGHUP (killing bash before cleanup runs), any unprocessed raw files are cleaned up automatically the next time a terminal opens.

## Uninstall
```bash
# Remove hook from ~/.bashrc (delete lines between the two auto-terminal-logger markers)
nano ~/.bashrc

sudo rm /usr/local/bin/cleanlog
rm -rf $HOME/Desktop/sessions/
```

## Requirements
Ubuntu / Debian · `bash` · `python3` · `util-linux` (pre-installed)
