#!/bin/bash

LOG_FILE="$HOME/connection_dropouts_log.txt"
TARGET="8.8.8.8"

while true; do
    ping -c 1 $TARGET > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Connection dropout detected at $(date +"%Y-%m-%d %H:%M:%S")" >> $LOG_FILE
    fi
    sleep 60 # Check every minute
done
