#!/bin/bash

LOG_FILE="$HOME/internet_latency_log.txt"
TARGET="8.8.8.8" # Google's DNS server as a test target

# Log date and time
echo "Date: $(date +"%Y-%m-%d %H:%M:%S")" >> $LOG_FILE
echo "Pinging $TARGET..." >> $LOG_FILE

# Ping and log the results
ping -c 10 $TARGET >> $LOG_FILE 2>&1
echo "----------------------------------" >> $LOG_FILE

echo "Latency test completed and logged."
