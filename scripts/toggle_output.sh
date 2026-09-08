#!/usr/bin/env bash
ACTION="$1" # "focus" or "move"
TARGET="$2"
PRIMARY="DP-2"

CURRENT=$(niri msg -j focused-output 2>/dev/null | jq -r .name)

DEST="$TARGET"
if [ "$CURRENT" = "$TARGET" ]; then
    DEST="$PRIMARY"
fi

if [ "$ACTION" = "focus" ]; then
    niri msg action focus-monitor "$DEST"
else
    niri msg action move-column-to-monitor "$DEST"
fi
