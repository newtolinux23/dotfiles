FROM python:3.9-slim

# Install speedtest-cli
RUN pip install speedtest-cli

# Copy the Python script into the container
COPY internet-monitoring.py /usr/local/bin/internet-monitoring.py

# Make the script executable
RUN chmod +x /usr/local/bin/internet-monitoring.py

# Set the entrypoint
ENTRYPOINT ["python", "/usr/local/bin/internet-monitoring.py"]
