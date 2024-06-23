#!/bin/bash

LOG_FILE="$HOME/service_outages_log.txt"
TARGET="8.8.8.8"

while true; do
    ping -c 1 $TARGET > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        START=$(date +"%Y-%m-%d %H:%M:%S")
        echo "Service outage started at $START" >> $LOG_FILE
        while [ $? -ne 0 ]; do
            ping -c 1 $TARGET > /dev/null 2>&1
            sleep 10
        done
        END=$(date +"%Y-%m-%d %H:%M:%S")
        echo "Service outage ended at $END" >> $LOG_FILE
        DURATION=$(( $(date -d "$END" +%s) - $(date -d "$START" +%s) ))
        echo "Outage duration: $DURATION seconds" >> $LOG_FILE
        echo "----------------------------------" >> $LOG_FILE
    fi
    sleep 60
done
