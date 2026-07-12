#!/usr/bin/env bash
if ! pgrep -x "spotify" | xargs -I {} ps -o state= -p {} | grep -qv "Z"; then
    exit 1
fi

setsid spicetify watch -s 2>&1 | sed "/Reloaded Spotify/q" &