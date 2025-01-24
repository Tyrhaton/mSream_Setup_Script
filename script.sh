#!/bin/bash

# Zorg dat het script stopt bij fouten
set -e

sudo su

param=$1

# Switch-case structuur
case $param in
run)

    echo "[+] Setup script for mStream music server started"

    # Controleer of het script met rootrechten wordt uitgevoerd
    if [ "$EUID" -ne 0 ]; then
        echo "[-] Run this script with sudo or as root"
        exit 1
    fi

    # Update systeem and install dependencies
    echo "[+] Updating system and installing required packages"
    apt update && apt upgrade -y
    apt install -y git nodejs npm ffmpeg

    # Clone the mStream-repository
    echo "[+] Clonen the mStream-repository"
    BASE_DIR="/home/rpi/mStream"
    if [ -d "$BASE_DIR" ]; then
        echo "Directory $BASE_DIR Already Exists. Deleting."
        rm -rf "$BASE_DIR"
    fi
    git clone https://github.com/IrosTheBeggar/mStream.git "$BASE_DIR"

    # Go to the base directory
    cd "$BASE_DIR"

    echo "[+] Setting up music librarie"
    # muziek conf
    mkdir /home/rpi/music

    #download music
    curl -L -o /home/rpi/music/audio.mp3 'https://docs.google.com/uc?export=download&id=1kjHk-m0vD6T0s33CaQFBvULRWhkCQ0nD'

    CONFIG_DIR="/home/rpi/mStream/save/conf"

    # Make the folder if it doesn't exist
    if [ ! -d "$CONFIG_DIR" ]; then
        echo "[+] Making config file: $CONFIG_DIR"
        mkdir -p "$CONFIG_DIR"
    fi

    # Make the config file
    echo "[+] Writing custom configurationfile config.json to $CONFIG_DIR"
    cat <<EOL >"/home/rpi/mStream/save/conf/config.json"
{
  "port": 3030,
  "secret": "b6j7j5e6u5g36ubn536uyn536unm5m67u5365vby435y54ymn",
  "folders": {
    "music": { 
        "root": "/home/rpi/music"
        }
  },
  "users": {}
}
EOL

    echo "[+] Succesfull build configuration"

    # go to the servers folder
    cd /home/rpi/mStream

    # install dependencies
    npm install

    # npm run-script wizard -j /home/rpi/mStream/save/conf/config.json
    sudo node cli-boot-wrapper.js -j /home/rpi/mStream/save/conf/config.json

    # Download README.md
    README_PATH = "https://raw.githubusercontent.com/Tyrhaton/mSream_Setup_Script/refs/heads/main/README.md"
    curl -o /home/rpi/mStream/SCRIPT_README.md $README_PATH

    ;;
start)
    echo "[+] Starting mStream music server"
    sudo node cli-boot-wrapper.js -j /home/rpi/mStream/save/conf/config.json

    ;;
help)
    echo "[+] Help Manual:"
    ;;
*)
    echo "[-] Unknown parameter: use 'run','start' or 'help'"
    ;;
esac
