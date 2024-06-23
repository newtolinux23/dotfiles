#!/bin/bash

LOG_FILE="$HOME/traceroute_log.txt"
TARGET="8.8.8.8"

# Log date and time
echo "Date: $(date +"%Y-%m-%d %H:%M:%S")" >> $LOG_FILE
echo "Traceroute to $TARGET..." >> $LOG_FILE

# Run traceroute and log the results
traceroute $TARGET >> $LOG_FILE 2>&1
echo "----------------------------------" >> $LOG_FILE

echo "Traceroute completed and logged."
