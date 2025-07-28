# LMS Music Server Installer

This script automates the installation and configuration of LMS (Logitech Media Server) and its dependencies on a Debian-based Linux system.

## Features

- Updates system packages
- Installs all required dependencies
- Builds and installs WT and LMS from source
- Configures LMS service and user
- Downloads a sample music file for testing
- Enables and starts LMS as a systemd service

---

## Usage

1. Run the script with root privileges:

    ```bash
    sudo bash music_server_installer.sh
    ```

2. After the script completes, find your device's IP address on the `wlan0` interface.

3. Access LMS web interface by navigating to:

    ```
    http://<your-ip-address>:5082
    ```

---

## Script Breakdown

### Step 1: Update system and install dependencies

Updates package lists and installs necessary development libraries and tools.

### Step 2: Install WT from source

Clones the WT library repository, builds, and installs it.

### Step 3: Install LMS from source

Clones the LMS repository, builds, and installs it.

### Step 4: Configure LMS

Copies configuration files, creates a system user and group, and prepares directories with correct permissions.

### Step 5: Add sample music

Downloads a test audio file to `/usr/music`.

### Step 6: Start LMS service

Enables LMS to start on boot and launches the service immediately.

### Step 7: Access LMS Web Interface

Shows the IP address on the `wlan0` interface so you can open LMS in a browser.

---

## Notes

- Ensure you have a working internet connection for cloning repositories and downloading dependencies.
- This script assumes you are running on a Debian-based system with `apt` package manager.
- Adjust network interface (`wlan0`) if your device uses a different interface.

## Manual setup

To use this system you also need to do the following steps

1. Visit `http://<your-ip-address>:5082`
2. Create an Admin account (on first time visiting the page)
3. refresh
4. login
5. Go to "Libraries" (second arrow from top right)
6. Add `/usr/music/` as a library
7. Go to "Scanner" (second arrow from top right)
8. Click "Scan Now"
9. After this you should be able to view the music files that are added in `/usr/music/`
