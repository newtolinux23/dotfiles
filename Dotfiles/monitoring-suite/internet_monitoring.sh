#!/bin/bash

# Define PID file and log directory
PIDFILE="/tmp/internet_monitoring.pid"
BASE_LOG_DIR="$HOME/internet_monitoring_logs"

# Function to start monitoring
start_monitoring() {
    # Ensure the base log directory exists
    mkdir -p $BASE_LOG_DIR

    # Create a new directory for this test run
    LOG_DIR="$BASE_LOG_DIR/$(date +"%Y-%m-%d_%H-%M-%S")"
    mkdir -p $LOG_DIR

    # Check if another instance is running, if so, stop it
    if [ -e $PIDFILE ] && kill -0 $(cat $PIDFILE); then
        echo "Stopping existing instance..."
        kill -9 $(cat $PIDFILE)
        rm -f $PIDFILE
    fi

    # Write the current PID to the PID file
    echo $$ > $PIDFILE

    # Trap to ensure the PID file is removed on script exit
    trap "rm -f $PIDFILE" EXIT

    echo "Starting monitoring suite..."
    while true; do
        run_internet_speed_test
        run_latency_check
        create_master_log
        convert_to_pdf
        sleep 1800  # Wait for 30 minutes before the next run
    done
}

# Function to run internet speed test with timeout
run_internet_speed_test() {
    LOG_FILE="$LOG_DIR/internet_speed_log.txt"
    echo "Running internet speed test..."
    timeout 30s speedtest-cli --simple >> $LOG_FILE 2>&1 || echo "Speedtest failed or timed out" >> $LOG_FILE
    echo "Internet speed test completed and logged."
}

# Function to run latency check with timeout
run_latency_check() {
    LOG_FILE="$LOG_DIR/internet_latency_log.txt"
    TARGET="8.8.8.8"
    echo "Running latency check..."
    timeout 30s ping -c 10 $TARGET >> $LOG_FILE 2>&1 || echo "Ping failed or timed out" >> $LOG_FILE
    echo "Latency check completed and logged."
}

# Function to monitor connection dropouts
run_connection_dropouts() {
    LOG_FILE="$LOG_DIR/connection_dropouts_log.txt"
    TARGET="8.8.8.8"
    echo "Starting connection dropouts monitoring..."
    while true; do
        timeout 5s ping -c 1 $TARGET > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "Connection dropout detected at $(date +"%Y-%m-%d %H:%M:%S")" >> $LOG_FILE
        fi
        sleep 60  # Wait for 1 minute before the next check
    done
}

# Function to monitor service outages
run_service_outages() {
    LOG_FILE="$LOG_DIR/service_outages_log.txt"
    TARGET="8.8.8.8"
    echo "Starting service outages monitoring..."
    while true; do
        timeout 5s ping -c 1 $TARGET > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            START=$(date +"%Y-%m-%d %H:%M:%S")
            echo "Service outage started at $START" >> $LOG_FILE
            while [ $? -ne 0 ]; do
                timeout 5s ping -c 1 $TARGET > /dev/null 2>&1
                sleep 10
            done
            END=$(date +"%Y-%m-%d %H:%M:%S")
            echo "Service outage ended at $END" >> $LOG_FILE
            DURATION=$(( $(date -d "$END" +%s) - $(date -d "$START" +%s) ))
            echo "Outage duration: $DURATION seconds" >> $LOG_FILE
            echo "----------------------------------" >> $LOG_FILE
        fi
        sleep 60  # Wait for 1 minute before the next check
    done
}

# Function to create a master log
create_master_log() {
    MASTER_LOG="$LOG_DIR/master_log.txt"
    echo "Creating master log..."
    echo "Internet Monitoring Log - $(date)" > $MASTER_LOG
    echo "----------------------------------" >> $MASTER_LOG

    echo "Internet Speed Test Log" >> $MASTER_LOG
    cat "$LOG_DIR/internet_speed_log.txt" >> $MASTER_LOG
    echo "----------------------------------" >> $MASTER_LOG

    echo "Latency Test Log" >> $MASTER_LOG
    cat "$LOG_DIR/internet_latency_log.txt" >> $MASTER_LOG
    echo "----------------------------------" >> $MASTER_LOG

    echo "Connection Dropouts Log" >> $MASTER_LOG
    cat "$LOG_DIR/connection_dropouts_log.txt" >> $MASTER_LOG
    echo "----------------------------------" >> $MASTER_LOG

    echo "Service Outages Log" >> $MASTER_LOG
    cat "$LOG_DIR/service_outages_log.txt" >> $MASTER_LOG
    echo "----------------------------------" >> $MASTER_LOG

    echo "Master log created at $MASTER_LOG"
}

# Function to convert master log to PDF
convert_to_pdf() {
    MASTER_LOG="$LOG_DIR/master_log.txt"
    PDF_FILE="$LOG_DIR/master_log.pdf"
    echo "Converting master log to PDF..."
    if command -v pandoc &> /dev/null; then
        pandoc "$MASTER_LOG" -o "$PDF_FILE"
        echo "PDF created at $PDF_FILE"
    else
        echo "Pandoc is not installed. Install pandoc to convert the log to PDF."
    fi
}

# Start connection dropouts and service outages monitoring in background
run_connection_dropouts &
run_service_outages &

# Start monitoring suite
start_monitoring
