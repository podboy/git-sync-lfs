#!/bin/bash

set -o pipefail

log() {
    if [ -n "$GITSYNC_EXECHOOK_LOGFILE" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$GITSYNC_EXECHOOK_LOGFILE"
    fi
}

normalize_path() {
    if [ -z "$1" ]; then
        echo ""
        return
    fi
    echo "$1" | sed 's#//*#/#g' | sed 's#/$##'
}

if ! command -v git-lfs &> /dev/null; then
    log "❌ git-lfs command not found"
    exit 1
fi

if [ -z "$GITSYNC_ROOT" ]; then
    log "⚠️ GITSYNC_ROOT environment variable not set"
    exit 0
fi

if [ -n "$GITSYNC_LINK" ]; then
    ROOT_DIR=$(normalize_path "${GITSYNC_ROOT}/${GITSYNC_LINK}")
else
    ROOT_DIR=$(normalize_path "${GITSYNC_ROOT}")
fi

if [ ! -d "$ROOT_DIR" ]; then
    log "❌ Directory does not exist: $ROOT_DIR"
    exit 1
fi

log "Current directory: $(pwd)"
log "Root directory: $ROOT_DIR"
log "Hash: $GITSYNC_HASH"
log "User: $(whoami)"

cd "$ROOT_DIR" || {
    log "❌ Failed to change directory to $ROOT_DIR"
    exit 1
}

if [ -n "$GITSYNC_EXECHOOK_LOGFILE" ]; then
    git lfs install 2>&1 | tee -a "$GITSYNC_EXECHOOK_LOGFILE" || {
        log "❌ git lfs install failed"
        exit 1
    }
    git lfs pull 2>&1 | tee -a "$GITSYNC_EXECHOOK_LOGFILE" || {
        log "❌ git lfs pull failed"
        exit 1
    }
else
    git lfs install || {
        log "❌ git lfs install failed"
        exit 1
    }
    git lfs pull || {
        log "❌ git lfs pull failed"
        exit 1
    }
fi

log "✅ Git LFS completed successfully"
exit 0
