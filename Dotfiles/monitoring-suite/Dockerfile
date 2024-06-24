# Use Fedora as the base image
FROM fedora:latest

# Update and install necessary packages
RUN dnf -y update && \
    dnf -y install speedtest-cli pandoc cronie iputils bind-utils texlive texlive-latex traceroute

# Create a directory for logs and PDF files
RUN mkdir -p /home/rob/internet_monitoring_logs

# Copy the monitoring script into the container
COPY internet_monitoring.sh /usr/local/bin/internet_monitoring.sh

# Set the working directory
WORKDIR /usr/local/bin

# Make the script executable
RUN chmod +x internet_monitoring.sh

# Create a user and switch to it
RUN useradd -ms /bin/bash rob
USER rob

# Execute the script when the container starts
CMD ["bash", "internet_monitoring.sh"]
