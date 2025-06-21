#!/bin/bash

PID=$(pgrep -x "Google Chrome" | head -n 1)

if [ -n "$PID" ]; then
  ELAPSED=$(ps -p "$PID" -o etimes= | tr -d ' ')

  if [ "$ELAPSED" -gt 3600 ]; then
    echo "Chrome has been running for more than an hour. Killing it..."
    kill "$PID"
  fi
fi
