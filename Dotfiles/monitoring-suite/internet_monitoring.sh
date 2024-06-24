#!/bin/bash
#!/bin/bash

# Toggle logging
LOGGING=true

if [ "$LOGGING" = true ]; then
    exec > >(tee -a /tmp/internet_monitoring.log) 2>&1
fi

echo "Script started at: $(date)"
echo "Current user: $(whoami)"

# Define a log directory with session timestamp
SESSION_TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
LOG_DIR="/home/rob/internet_monitoring_logs/$SESSION_TIMESTAMP"
echo "Log directory: $LOG_DIR"
mkdir -p "$LOG_DIR"

# Define a lock file to ensure only one instance runs at a time
LOCKFILE="/tmp/internet_monitoring.lock"

# Check if another instance is running and exit if true
if [ -f "$LOCKFILE" ] && kill -0 "$(cat "$LOCKFILE")"; then
    echo "Another instance is already running. Exiting."
    exit 1
fi

# Write the current PID to the lock file
echo $$ > "$LOCKFILE"

# Trap to ensure the lock file is removed on script exit
trap "rm -f $LOCKFILE" EXIT

# Function to perform an internet speed test
run_internet_speed_test() {
    echo "Running internet speed test..."
    if command -v speedtest-cli > /dev/null; then
        timeout 60 speedtest-cli --simple >> "$LOG_DIR/internet_speed_log.txt" 2>&1
        if [ $? -ne 0 ]; then
            echo "Error: speedtest-cli failed or timed out" >> "$LOG_DIR/error_log.txt"
        else
            echo "Internet speed test completed and logged."
        fi
    else
        echo "Error: speedtest-cli is not installed" >> "$LOG_DIR/error_log.txt"
    fi
}

# Function to perform a latency check
run_latency_check() {
    echo "Running latency check..."
    timeout 60 ping -c 10 8.8.8.8 >> "$LOG_DIR/internet_latency_log.txt" 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: ping failed or timed out" >> "$LOG_DIR/error_log.txt"
    else
        echo "Latency check completed and logged."
    fi
}

# Function to perform jitter measurement
run_jitter_measurement() {
    echo "Running jitter measurement..."
    timeout 60 ping -c 100 8.8.8.8 | awk -F'=' '/time=/ {print $NF}' | sed 's/ ms//' > "$LOG_DIR/jitter_log.txt"
    awk '{delta=$1-last; last=$1; if (NR>1) {print (delta<0 ? -delta : delta); sum+=delta}} END {print "Average jitter:", sum/NR, "ms"}' "$LOG_DIR/jitter_log.txt" >> "$LOG_DIR/internet_latency_log.txt"
    if [ $? -ne 0 ]; then
        echo "Error: jitter measurement failed or timed out" >> "$LOG_DIR/error_log.txt"
    else
        echo "Jitter measurement completed and logged."
    fi
}

# Function to measure packet loss
measure_packet_loss() {
    echo "Measuring packet loss..."
    timeout 60 ping -c 100 8.8.8.8 | grep 'packet loss' >> "$LOG_DIR/internet_latency_log.txt"
    if [ $? -ne 0 ]; then
        echo "Error: packet loss measurement failed or timed out" >> "$LOG_DIR/error_log.txt"
    else
        echo "Packet loss measurement completed and logged."
    fi
}

# Function to run traceroute
run_traceroute() {
    echo "Running traceroute..."
    timeout 60 traceroute 8.8.8.8 > "$LOG_DIR/traceroute_log.txt"
    if [ $? -ne 0 ]; then
        echo "Error: traceroute failed or timed out" >> "$LOG_DIR/error_log.txt"
    else
        echo "Traceroute completed and logged."
    fi
}

# Function to measure DNS resolution time
measure_dns_resolution_time() {
    echo "Measuring DNS resolution time..."
    dig google.com | grep 'Query time' >> "$LOG_DIR/dns_resolution_log.txt"
    if [ $? -ne 0 ]; then
        echo "Error: DNS resolution time measurement failed" >> "$LOG_DIR/error_log.txt"
    else
        echo "DNS resolution time measurement completed and logged."
    fi
}

# Function to measure latency to multiple endpoints
measure_multi_endpoint_latency() {
    echo "Measuring latency to multiple endpoints..."
    for host in google.com cloudflare.com facebook.com; do
        echo "Pinging $host" >> "$LOG_DIR/multi_endpoint_latency_log.txt"
        timeout 60 ping -c 10 $host | grep 'time=' >> "$LOG_DIR/multi_endpoint_latency_log.txt"
        if [ $? -ne 0 ]; then
            echo "Error: ping to $host failed or timed out" >> "$LOG_DIR/error_log.txt"
        else
            echo "Ping to $host completed and logged."
        fi
    done
}

# Function to create a master log
create_master_log() {
    echo "Creating master log..."
    {
        echo "Internet Monitoring Log - $SESSION_TIMESTAMP"
        echo "----------------------------------"
        echo "Internet Speed Test Log"
        cat "$LOG_DIR/internet_speed_log.txt"
        echo "----------------------------------"
        echo "Latency Test Log"
        cat "$LOG_DIR/internet_latency_log.txt"
        echo "----------------------------------"
        echo "Jitter Measurement"
        cat "$LOG_DIR/jitter_log.txt"
        echo "----------------------------------"
        echo "Packet Loss Measurement"
        cat "$LOG_DIR/internet_latency_log.txt" | grep 'packet loss'
        echo "----------------------------------"
        echo "Traceroute Log"
        cat "$LOG_DIR/traceroute_log.txt"
        echo "----------------------------------"
        echo "DNS Resolution Time"
        cat "$LOG_DIR/dns_resolution_log.txt"
        echo "----------------------------------"
        echo "Multi-Endpoint Latency"
        cat "$LOG_DIR/multi_endpoint_latency_log.txt"
        echo "----------------------------------"
        if [ -f "$LOG_DIR/error_log.txt" ]; then
            echo "Errors:"
            cat "$LOG_DIR/error_log.txt"
        fi
    } > "$LOG_DIR/master_log.txt"
    echo "Master log created at $LOG_DIR/master_log.txt"
}

# Function to convert master log to PDF
convert_master_log_to_pdf() {
    echo "Converting master log to PDF..."
    if command -v pandoc > /dev/null; then
        pandoc "$LOG_DIR/master_log.txt" -o "$LOG_DIR/master_log.pdf" --pdf-engine=pdflatex
        if [ $? -ne 0 ]; then
            echo "Error: pandoc failed to create PDF" >> "$LOG_DIR/error_log.txt"
        else
            echo "PDF created at $LOG_DIR/master_log.pdf"
        fi
    else
        echo "Pandoc is not installed. Skipping PDF conversion."
    fi
}

# Run the monitoring tasks
run_internet_speed_test
run_latency_check
run_jitter_measurement
measure_packet_loss
run_traceroute
measure_dns_resolution_time
measure_multi_endpoint_latency
create_master_log
convert_master_log_to_pdf

echo "Script completed at: $(date)"
