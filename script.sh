#!/bin/bash

# Stop execution if any command fails
set -e

param=$1

# Switch-case structure
case $param in
run)

    echo "[+] Starting mStream music server setup..."

    # Ensure the script is run as root
    if [ "$EUID" -ne 0 ]; then
        echo "[-] Run this script with sudo or as root"
        exit 1
    fi

    # STEP 1: Check and Install Node.js (if missing or outdated)
    echo "[+] Checking Node.js installation..."
    NODE_VERSION=$(node -v 2>/dev/null || echo "not_installed")
    REQUIRED_NODE_VERSION="v20"

    if [[ $NODE_VERSION != $REQUIRED_NODE_VERSION* ]]; then
        echo "[-] Node.js is not installed or outdated. Installing Node.js 20 LTS..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
        apt install -y nodejs
    else
        echo "[+] Node.js is already installed: $NODE_VERSION"
    fi

    # Verify Node.js and npm versions
    node -v
    npm -v

    # STEP 2: Fix npm global package permissions
    echo "[+] Fixing npm permissions..."
    mkdir -p ~/.npm-global
    npm config set prefix '~/.npm-global'
    echo 'export PATH=$HOME/.npm-global/bin:$PATH' >> ~/.bashrc
    source ~/.bashrc

    # STEP 3: Check and Install Required Packages
    echo "[+] Checking and installing required packages..."
    apt update && apt upgrade -y
    for package in git ffmpeg curl ufw; do
        if ! dpkg -l | grep -q "^ii  $package"; then
            echo "[-] $package is not installed. Installing..."
            apt install -y $package
        else
            echo "[+] $package is already installed."
        fi
    done

    # STEP 4: Clone the mStream repository if not already present
    BASE_DIR="/home/rpi/mStream"
    if [ -d "$BASE_DIR" ]; then
        echo "[+] mStream directory already exists. Skipping cloning."
    else
        echo "[+] Cloning the mStream repository..."
        git clone https://github.com/IrosTheBeggar/mStream.git "$BASE_DIR"
    fi

    # Go to the base directory
    cd "$BASE_DIR"

    # STEP 5: Fix file permissions
    echo "[+] Fixing mStream file permissions..."
    chown -R nout:nout "$BASE_DIR"
    chmod -R 775 "$BASE_DIR"

    # STEP 6: Create a music directory
    MUSIC_DIR="/home/rpi/music"
    mkdir -p "$MUSIC_DIR"
    echo "[+] Music directory created at $MUSIC_DIR"

    # Download a sample music file
    if [ ! -f "$MUSIC_DIR/audio.mp3" ]; then
        echo "[+] Downloading sample music file..."
        curl -L -o "$MUSIC_DIR/audio.mp3" 'https://docs.google.com/uc?export=download&id=1kjHk-m0vD6T0s33CaQFBvULRWhkCQ0nD'
    else
        echo "[+] Sample music file already exists. Skipping download."
    fi

    # STEP 7: Create mStream configuration
    CONFIG_DIR="$BASE_DIR/save/conf"
    mkdir -p "$CONFIG_DIR"

    echo "[+] Writing custom configuration file..."
    cat <<EOL >"$CONFIG_DIR/config.json"
{
  "port": 3030,
  "bind_ip": "0.0.0.0",
  "secret": "b6j7j5e6u5g36ubn536uyn536unm5m67u5365vby435y54ymn",
  "folders": {
    "music": { 
        "root": "$MUSIC_DIR"
    }
  },
  "users": {}
}
EOL

    # STEP 8: Install mStream dependencies
    echo "[+] Installing mStream dependencies..."
    npm install

    # STEP 9: Create a systemd service for mStream
    echo "[+] Creating systemd service for mStream..."
    SERVICE_FILE="/etc/systemd/system/mstream.service"
    cat <<EOL > "$SERVICE_FILE"
[Unit]
Description=mStream Music Server
After=network.target

[Service]
ExecStart=/usr/bin/node /home/rpi/mStream/cli-boot-wrapper.js -j /home/rpi/mStream/save/conf/config.json
Restart=always
User=nout
Group=nout

[Install]
WantedBy=multi-user.target
EOL

    # Reload systemd and enable the service
    systemctl daemon-reload
    systemctl enable mstream
    systemctl start mstream

    # Get local IP address
    LOCAL_IP=$(hostname -I | awk '{print $1}')

    echo "[+] mStream server setup completed!"
    echo "Access the server locally at: http://$LOCAL_IP:3030"
    echo "If you want others to access it, use port forwarding on your router for port 3030."

    ;;
start)
    echo "[+] Starting mStream music server..."
    systemctl start mstream
    ;;
help)
    echo "[+] Help Manual:"
    echo "  run   - Setup and configure the mStream music server"
    echo "  start - Start the mStream server"
    echo "  help  - Display this help manual"
    ;;
*)
    echo "[-] Unknown parameter: use 'run', 'start', or 'help'"
    ;;
esac
