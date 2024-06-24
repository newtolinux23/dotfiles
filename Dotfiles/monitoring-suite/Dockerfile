# Use a base image with Fedora
FROM fedora:latest

# Install necessary packages
RUN dnf -y update && \
    dnf -y install speedtest-cli pandoc cronie

# Copy the script into the container
COPY internet_monitoring.sh /usr/local/bin/internet_monitoring.sh

# Make the script executable
RUN chmod +x /usr/local/bin/internet_monitoring.sh

# Set up a cron job
RUN echo "0 */4 * * * /usr/local/bin/internet_monitoring.sh >> /var/log/internet_monitoring.log 2>&1" > /etc/cron.d/internet_monitoring && \
    crontab /etc/cron.d/internet_monitoring

# Set the entrypoint to cron
ENTRYPOINT ["crond", "-n"]
