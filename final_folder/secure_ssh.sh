#!/bin/bash

# Generate an SSH key pair if it doesn't already exist
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa

# Prompt user for Raspberry Pi details
read -p "Enter the Raspberry Pi username: " USER
read -p "Enter the Raspberry Pi IP or hostname: " PI_HOST

# Copy the public SSH key to the Raspberry Pi for passwordless login
echo "[+] Copying public key to Raspberry Pi ($USER@$PI_HOST)..."
ssh-copy-id -i "$HOME/.ssh/id_rsa.pub" "$USER@$PI_HOST"

# Test SSH connection to confirm setup
echo "[+] Testing SSH connection..."
ssh "$USER@$PI_HOST" "echo 'SSH key authentication successful!'"
