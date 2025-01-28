#!/bin/bash
set -e

param=$1
param2=$2

# Switch-case structure
case $param in
run)

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
        curl -O "https://nodejs.org/dist/$REQUIRED_NODE_VERSION/node-$REQUIRED_NODE_VERSION.tar.gz"
        tar -xzf "node-$REQUIRED_NODE_VERSION.tar.gz"
        cd "node-$REQUIRED_NODE_VERSION"

        ./configure
        make -j$(nproc)
        sudo make install

        cd ~
        sudo rm -rf "$BUILD_DIR"
        ;;
    n)
        echo "[+] Installing Node.js from the official repository..."
        curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
        sudo apt install -y nodejs
        ;;
    *)
        echo "[-] Invalid input. Exiting..."
        exit 1
        ;;
    esac

    echo "[+] Verifying Node.js and npm versions..."
    node -v
    npm -v

    echo "[+] Node.js $REQUIRED_NODE_VERSION has been successfully installed."
else
    echo "[+] Node.js is already installed: $INSTALLED_NODE_VERSION"
fi

# STEP 2: Fix npm permissions
echo "[+] Fixing npm permissions..."
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=$HOME/.npm-global/bin:$PATH' >>~/.bashrc
source ~/.bashrc

# STEP 3: Check and Install Required Packages
echo "[+] Installing required packages for mStream..."
npm install -g mstream

# STEP 4: Configure UFW Firewall
echo "[+] Configuring UFW firewall..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp  # SSH
sudo ufw allow 3030/tcp  # mStream
sudo ufw --force enable

# STEP 5: Create a systemd service for mStream
echo "[+] Creating systemd service for mStream..."
SERVICE_FILE="/etc/systemd/system/mstream.service"
sudo bash -c "cat <<EOL >$SERVICE_FILE
[Unit]
Description=mStream Music Server
After=network.target

[Service]
ExecStart=$(which mstream)
Restart=always
User=$(whoami)

[Install]
WantedBy=multi-user.target
EOL"

sudo systemctl daemon-reload
sudo systemctl enable mstream
sudo systemctl start mstream

echo "[+] mStream is now installed and running on port 3030."
;;
*)
    echo "[-] Invalid parameter. Use 'run' to execute the script."
    exit 1
    ;;
esac
