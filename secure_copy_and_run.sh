#!/bin/bash

# Generate an SSH key pair if it doesn't already exist
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
    echo "[+] Generating new SSH key pair..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
else
    echo "[+] SSH key pair already exists. Skipping key generation."
fi

# Prompt user for Raspberry Pi details
read -p "Enter the Raspberry Pi username: " USER
read -p "Enter the Raspberry Pi IP or hostname: " PI_HOST

# Copy the public SSH key to the Raspberry Pi for passwordless login
echo "[+] Copying public key to Raspberry Pi ($USER@$PI_HOST)..."
ssh-copy-id -i "$HOME/.ssh/id_rsa.pub" "$USER@$PI_HOST"

# Test SSH connection to confirm setup
echo "[+] Testing SSH connection..."
ssh "$USER@$PI_HOST" "echo 'SSH key authentication successful!'"

# Copy script.sh to the Raspberry Pi
SCRIPT_NAME="script.sh"
echo "[+] Copying $SCRIPT_NAME to Raspberry Pi..."
scp "$SCRIPT_NAME" "$USER@$PI_HOST:/home/$USER/"

# Make script executable
echo "[+] Making $SCRIPT_NAME executable on Raspberry Pi..."
ssh "$USER@$PI_HOST" "chmod +x /home/$USER/$SCRIPT_NAME"

# Run the script on the Raspberry Pi with sudo
echo "[+] Running $SCRIPT_NAME on Raspberry Pi as sudo..."
read -p "[=] Install from source? (y/n) " installFromSource
if [ "$installFromSource" = "y" ]; then
    ssh "$USER@$PI_HOST" "sudo /home/$USER/$SCRIPT_NAME run -source"

else
    ssh "$USER@$PI_HOST" "sudo /home/$USER/$SCRIPT_NAME run -precompiled"

fi

echo "[+] Done!"
