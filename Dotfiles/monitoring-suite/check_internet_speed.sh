#!/bin/bash

# Check if speedtest-cli is installed, if not, install it
if ! command -v speedtest-cli &> /dev/null
then
    echo "speedtest-cli not found. Installing..."
    sudo dnf install -y speedtest-cli
fi

# Log file path
LOG_FILE="$HOME/internet_speed_log.txt"

# Function to log the current date and time
log_date() {
    echo "Date: $(date +"%Y-%m-%d %H:%M:%S")" >> $LOG_FILE
}

# Function to log speedtest results
log_speedtest() {
    echo "Running speedtest..." >> $LOG_FILE
    speedtest-cli --simple >> $LOG_FILE 2>&1
    echo "----------------------------------" >> $LOG_FILE
}

# Log the date and time
log_date

# Log the speedtest results
log_speedtest

# Print a message indicating that the test is complete
echo "Internet speed test completed and logged."
