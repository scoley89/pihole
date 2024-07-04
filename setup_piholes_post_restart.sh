#!/bin/bash

# Function to resume setup after restart
resume_setup() {
    # Function to setup Pi-hole (resume)
    setup_pihole() {
        # Set a password for web admin interface
        sudo pihole -a -p "$PIHOLE_PASSWORD"

        # Download and apply default block lists
        sudo wget -O /etc/pihole/adlists.list "$BLOCKLIST_URL"
        sudo pihole -g

        # Enable and start Pi-hole service
        sudo systemctl enable pihole-FTL
        sudo systemctl start pihole-FTL
    }

    # Function to setup passwordless SSH access (resume)
    setup_ssh() {
        # Copy SSH public key to authorized_keys
        mkdir -p /home/pi/.ssh
        echo "$SSH_PUBLIC_KEY" >> /home/pi/.ssh/authorized_keys
        chown -R pi:pi /home/pi/.ssh
        chmod 700 /home/pi/.ssh
        chmod 600 /home/pi/.ssh/authorized_keys

        # Disable password authentication and root login
        sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
        sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

        # Restart SSH service
        sudo systemctl restart ssh
    }

    # Function to install .PADD (resume)
    install_padd() {
        # Clone .PADD repository
        git clone https://github.com/jpmck/PADD.git
        cd PADD

        # Install .PADD dependencies (e.g., pygame)
        sudo apt install python3-pygame -y

        # Configure .PADD to start on boot
        echo "@reboot pi cd /home/pi/PADD && python3 PADD.py &" | crontab -u pi -

        # Start .PADD
        python3 PADD.py &
    }

    # Function to install drivers for common 3.5 inch touch screens (resume)
    install_touchscreen_drivers() {
        # Install Waveshare drivers (adjust for specific touchscreen model)
        # Example for Waveshare 3.5 inch RPi LCD (A/B)
        cd LCD-show

        # Run specific script for installation (adjust based on your touchscreen model)
        sudo ./LCD35-show  # Example command for Waveshare 3.5 inch

        # Reboot to apply changes
        sudo reboot
    }

    # Call functions to resume setup
    setup_pihole
    setup_ssh
    install_padd
    install_touchscreen_drivers
}

# Call function to resume setup after restart
resume_setup

