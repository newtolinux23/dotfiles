#!/bin/bash

# Run Internet Speed Test
echo "Running Internet Speed Test..."
/path/to/check_internet_speed.sh

# Run Latency and Packet Loss Test
echo "Running Latency and Packet Loss Test..."
/path/to/check_latency.sh

# Run Traceroute Test
echo "Running Traceroute Test..."
/path/to/check_traceroute.sh

# Start Monitoring Connection Dropouts in the Background
echo "Starting Connection Dropouts Monitoring..."
nohup /path/to/monitor_connection_dropouts.sh &

# Start Monitoring Service Outages in the Background
echo "Starting Service Outages Monitoring..."
nohup /path/to/monitor_service_outages.sh &

echo "Monitoring suite initiated."
