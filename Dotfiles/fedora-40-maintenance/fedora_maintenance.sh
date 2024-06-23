#!/bin/bash

# Script for Fedora 40 System Maintenance
# Script Description: This Bash script is designed to perform essential maintenance tasks on a Fedora 40 system. The script automates a series of routine operations to ensure the system remains up-to-date, secure, and running efficiently.

# Function to print a message
function print_message {
    echo -e "\n==================================="
    echo "$1"
    echo "===================================\n"
}

# Update the system
print_message "Updating the system"
sudo dnf update -y

# Clean up old packages
print_message "Cleaning up old packages"
sudo dnf autoremove -y
sudo dnf clean all

# Check for disk errors
print_message "Checking for disk errors"
sudo fsck -A -y

# Remove orphaned packages
print_message "Removing orphaned packages"
sudo dnf remove $(dnf repoquery --extras) -y

# Check and repair the RPM database
print_message "Checking and repairing RPM database"
sudo rpm --rebuilddb

# Check the status of critical services with a timeout
print_message "Checking the status of critical services"
SERVICES=("sshd" "firewalld" "crond")
for SERVICE in "${SERVICES[@]}"
do
    timeout 5s sudo systemctl is-active $SERVICE &> /dev/null
    if [ $? -eq 0 ]; then
        echo "$SERVICE is active."
    else
        echo "$SERVICE is not active or the check timed out."
    fi
done

# Remove unused kernel versions
print_message "Removing unused kernel versions"
sudo dnf remove $(dnf repoquery --installonly --latest-limit=-2 -q) -y

# Update Flatpak packages
print_message "Updating Flatpak packages"
flatpak update -y

# Clear systemd journal logs older than 2 weeks
print_message "Clearing systemd journal logs older than 2 weeks"
sudo journalctl --vacuum-time=2weeks

# Check for broken dependencies
print_message "Checking for broken dependencies"
sudo dnf check

# Clean up Docker (if Docker is installed)
if command -v docker &> /dev/null
then
    print_message "Cleaning up Docker"
    sudo docker system prune -f
fi

# Notify maintenance completion
print_message "System maintenance completed successfully!"

# Optionally, you could reboot the system if needed
# print_message "Rebooting the system"
# sudo reboot
