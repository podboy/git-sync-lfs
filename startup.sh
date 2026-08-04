#!/bin/sh

set -e

find_locks() {
    local dir="$1"
    for item in "$dir"/*; do
        if [ -f "$item" ] && [ "$(basename "$item")" = "index.lock" ]; then
            echo "$item"
        elif [ -d "$item" ]; then
            find_locks "$item"
        fi
    done
}

if [ -z "$GITSYNC_ROOT" ]; then
    echo "ℹ️ GITSYNC_ROOT is not set"
elif [ ! -d "$GITSYNC_ROOT" ] || [ ! -d "$GITSYNC_ROOT/.git" ]; then
    echo "ℹ️ Root directory $GITSYNC_ROOT/.git does not exist"
else
    echo "🔍 Clean up Git lock files ..."

    if [ -f "$GITSYNC_ROOT/.git/index.lock" ]; then
        echo "🗑️ Remove $GITSYNC_ROOT/.git/index.lock"
        rm -f "$GITSYNC_ROOT/.git/index.lock"
    else
        echo "✅ No index.lock found in home directory"
    fi

    WORKTREES_DIR="$GITSYNC_ROOT/.git/worktrees"

    if [ -d "$WORKTREES_DIR" ]; then
        echo "🔍 Clean up worktrees directory lock files"
        LOCK_FILES=$(find_locks "$WORKTREES_DIR" || true)
        if [ -n "$LOCK_FILES" ]; then
            echo "$LOCK_FILES" | while read -r LOCK_FILE; do
                echo "🗑️ Remove $LOCK_FILE"
                rm -f "$LOCK_FILE"
            done
            echo "✅ Clean up worktrees directory lock files complete"
        else
            echo "✅ No index.lock files found in worktrees directory"
        fi
    else
        echo "ℹ️ Worktrees directory not found"
    fi

    echo "✅ Clean up Git lock files complete"
fi

echo "🚀 Start git-sync with arguments: $@"
exec /git-sync "$@"
