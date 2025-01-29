#!/bin/bash

# Stop execution if any command fails
set -e

param=$1
param2=$2

# Get the current logged-in user and home directory
CURRENT_USER=$(logname)
USER_HOME=$(eval echo ~$CURRENT_USER)

# Ensure script is running as root
if [ "$EUID" -ne 0 ]; then
    echo "[-] Run this script with sudo or as root"
    exit 1
fi

case $param in
run)

    echo "[+] Starting mStream music server setup for user: $CURRENT_USER..."

    # STEP 1: Check and Install Node.js (if missing or outdated)
    echo "[+] Checking Node.js installation..."
    INSTALLED_NODE_VERSION=$(node -v 2>/dev/null || echo "not_installed")
    REQUIRED_NODE_VERSION="v22.13.1"

    if [[ $INSTALLED_NODE_VERSION != $REQUIRED_NODE_VERSION* ]]; then
        echo "[-] Node.js is not installed or outdated. Installing Node.js $REQUIRED_NODE_VERSION..."

        if [ "$param2" = "-source" ]; then
            installFromSource=y
        else
            read -p "[=] Install from source? (y/n) " installFromSource
        fi

        case $installFromSource in
        y)
            echo "[+] Installing Node.js from source..."
            sudo apt update && sudo apt install -y build-essential python3 g++ make curl
            BUILD_DIR="/tmp/nodejs-build"
            mkdir -p "$BUILD_DIR"
            cd "$BUILD_DIR"

            echo "[+] Downloading Node.js sourcecode (version $REQUIRED_NODE_VERSION)"
            curl -O "https://nodejs.org/dist/$REQUIRED_NODE_VERSION/node-$REQUIRED_NODE_VERSION.tar.gz"

            echo "[+] Extracting Node.js sourcecode"
            tar -xzf "node-$REQUIRED_NODE_VERSION.tar.gz"
            cd "node-$REQUIRED_NODE_VERSION"

            echo "[+] Configuring Node.js"
            ./configure

            echo "[+] Building Node.js on all cores"
            make -j$(nproc)

            echo "[+] Installing Node.js version $REQUIRED_NODE_VERSION"
            sudo make install

            echo "[+] Cleaning up build files"
            cd ~
            sudo rm -rf "$BUILD_DIR"

            echo "[+] Verifying Node.js and npm versions"
            ;;
        n)
            echo "[+] Installing Node.js from the official repository"
            curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
            apt install -y nodejs
            ;;
        *)
            echo "[-] Invalid input. Exiting..."
            exit 1
            ;;
        esac
        node -v
        npm -v
        echo "[+] Node.js $REQUIRED_NODE_VERSION has been successfully installed"
    else
        echo "[+] Node.js is already installed: $INSTALLED_NODE_VERSION"
    fi

    node -v
    npm -v

    # STEP 2: Fix npm global package permissions
    echo "[+] Fixing npm permissions..."
    mkdir -p "$USER_HOME/.npm-global"
    sudo -u "$CURRENT_USER" npm config set prefix "$USER_HOME/.npm-global"
    echo 'export PATH=$HOME/.npm-global/bin:$PATH' >> "$USER_HOME/.bashrc"
    source "$USER_HOME/.bashrc"

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

    # STEP 4: Configure UFW Firewall
    echo "[+] Configuring UFW firewall..."
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22/tcp  # SSH
    ufw allow 3030/tcp  # mStream
    ufw --force enable

    # STEP 5: Clone the mStream repository
    BASE_DIR="$USER_HOME/mStream"
    if [ -d "$BASE_DIR" ]; then
        echo "[+] mStream directory already exists. Skipping cloning."
    else
        echo "[+] Cloning the mStream repository..."
        sudo -u "$CURRENT_USER" git clone https://github.com/IrosTheBeggar/mStream.git "$BASE_DIR"
    fi

    # STEP 6: Fix file permissions
    echo "[+] Fixing mStream file permissions..."
    chown -R "$CURRENT_USER:$CURRENT_USER" "$BASE_DIR"
    chmod -R 775 "$BASE_DIR"

    # STEP 7: Create a music directory
    MUSIC_DIR="$USER_HOME/music"
    mkdir -p "$MUSIC_DIR"
    echo "[+] Music directory created at $MUSIC_DIR"

    # Download a sample music file
    if [ ! -f "$MUSIC_DIR/audio.mp3" ]; then
        echo "[+] Downloading sample music file..."
        sudo -u "$CURRENT_USER" curl -L -o "$MUSIC_DIR/audio.mp3" 'https://docs.google.com/uc?export=download&id=1kjHk-m0vD6T0s33CaQFBvULRWhkCQ0nD'
    else
        echo "[+] Sample music file already exists. Skipping download."
    fi

    # STEP 8: Create mStream configuration
    CONFIG_DIR="$BASE_DIR/save/conf"
    mkdir -p "$CONFIG_DIR"

    echo "[+] Writing custom configuration file..."
    cat <<EOL >"$CONFIG_DIR/config.json"
{
  "port": 3030,
  "bind_ip": "0.0.0.0",
  "secret": "your-secure-key",
  "folders": {
    "music": { 
        "root": "$MUSIC_DIR"
    }
  },
  "users": {}
}
EOL

    # STEP 9: Install mStream dependencies
    echo "[+] Installing mStream dependencies..."
    sudo -u "$CURRENT_USER" npm install

    # STEP 10: Create a systemd service for mStream
    echo "[+] Creating systemd service for mStream..."
    SERVICE_FILE="/etc/systemd/system/mstream.service"
    cat <<EOL >"$SERVICE_FILE"
[Unit]
Description=mStream Music Server
After=network.target

[Service]
ExecStart=/usr/bin/node $BASE_DIR/cli-boot-wrapper.js -j $CONFIG_DIR/config.json
Restart=always
User=$CURRENT_USER
Group=$CURRENT_USER

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
