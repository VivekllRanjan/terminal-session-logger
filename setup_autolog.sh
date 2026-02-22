#!/bin/bash

# =============================================================
#  Auto Terminal Logger - Setup Script
# =============================================================

LOG_DIR="$HOME/Desktop/sessions"
BASHRC="$HOME/.bashrc"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$LOG_DIR"
echo "✅ Log directory ready: $LOG_DIR"

sudo cp "$SCRIPT_DIR/cleanlog.py" /usr/local/bin/cleanlog
sudo chmod +x /usr/local/bin/cleanlog
echo "✅ Cleaner installed at: /usr/local/bin/cleanlog"

MARKER="# >>> auto-terminal-logger <<<"
if grep -q "$MARKER" "$BASHRC"; then
    echo "⚠️  Removing old auto-logger from ~/.bashrc..."
    sed -i "/# >>> auto-terminal-logger <<</,/# <<< auto-terminal-logger <<</d" "$BASHRC"
fi

cat >> "$BASHRC" << 'BASHRC_BLOCK'

# >>> auto-terminal-logger <<<
if [ -z "$SCRIPT_RUNNING" ] && [ -n "$PS1" ]; then
    export SCRIPT_RUNNING=1
    LOG_DIR="$HOME/Desktop/sessions"
    mkdir -p "$LOG_DIR"

    # Clean any raw logs left over from previously closed terminals
    for RAW_OLD in /tmp/.term_raw_*.log; do
        [ -f "$RAW_OLD" ] || continue
        TS=$(basename "$RAW_OLD" | sed 's/.term_raw_//;s/_[0-9]*\.log//')
        /usr/local/bin/cleanlog "$RAW_OLD" "$LOG_DIR/${TS}.log" && rm -f "$RAW_OLD"
    done

    # Start recording this session
    TIMESTAMP=$(date +'%d%b_%H:%M')
    RAW="/tmp/.term_raw_${TIMESTAMP}_$$.log"

    # Also try to clean up on normal exit (typed 'exit' or Ctrl+D)
    trap "/usr/local/bin/cleanlog '$RAW' '$LOG_DIR/${TIMESTAMP}.log' && rm -f '$RAW'" EXIT

    script -q -e -f "$RAW"
fi
# <<< auto-terminal-logger <<<
BASHRC_BLOCK

echo "✅ Auto-logger added to ~/.bashrc"
echo ""
echo "🎉 Done! Open a new terminal, use it, close it."
echo "   Log appears in $HOME/Desktop/sessions/ when you open the next terminal."
