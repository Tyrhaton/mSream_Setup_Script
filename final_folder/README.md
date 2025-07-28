
# Music Server Installer Suite

This project provides a unified installer script for setting up one of three music streaming servers on a Debian-based Linux system (e.g., Raspberry Pi): LMS (Logitech Media Server), mStream, or Icecast with Ezstream.

The script handles setup and configuration for each option and is designed to streamline installation with minimal user intervention.

---

## Supported Music Servers

- **LMS (Logitech Media Server)** – Feature-rich home media server.
- **mStream** – Lightweight personal music streaming server.
- **Icecast + Ezstream** – Live audio broadcasting solution using HTTP streaming.

---

## Quick Start

### Step 1: Setup Files

Move all installer files into your home directory:

```bash
mv *.sh ~/
cd ~/
```

### Step 2: Make Scripts Executable

```bash
chmod +x icecast.sh lms.sh mstream.sh music_server_installer.sh
```

### Step 3: Run the Installer

```bash
sudo ./music_server_installer.sh
```

You'll be prompted to choose which server to install:

Choose a music server to run:

- Icecast

- LMS

- MStream

---

## LMS (Logitech Media Server)

### Features

- Installs all required dependencies
- Builds and installs WT and LMS from source
- Configures LMS systemd service
- Adds sample audio file for testing
- Access LMS via browser on port 5082

### Access

```bash
http://<your-ip-address>:5082
```

### Installation Steps LMS

1. Updates system packages
2. Installs dependencies and development tools
3. Builds WT (Web Toolkit) from source
4. Clones, builds, and installs LMS
5. Sets up LMS configuration, system user, and permissions
6. Adds a sample .mp3 file to `/usr/music/`
7. Enables and starts the LMS systemd service

### Manual setup

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

### Notes

- Make sure your device is connected to the internet
- Adjust the interface name (wlan0) if you're not using Wi-Fi

---

## mStream Server Setup

mStream is a personal music streaming server you can host and access from any device on your network.

### Installation Options

#### Option 1: Run From Your Local Machine

1. Download the repo and run `secure_copy_and_run.sh`
2. Enter the server's:
   - Username
   - Hostname or IP
   - Build option (type N to skip building Node.js from source)

#### Option 2: Run Directly on the Server

```bash
./script.sh run
```

 Or, to build Node.js from source

```bash
./script.sh run -source
```

## Access and Usage

- **Web interface**: `http://<IP_ADDRESS>:3030`
- **To start the server**: `./script.sh start`
- **Upload music to**: `/home/<USER>/music/`

---

## Icecast + Ezstream Streaming Server

Sets up a streaming solution using Icecast and Ezstream for broadcasting audio over the local network or internet.

### Components

- **Icecast** – HTTP-based media streaming server
- **Ezstream** – Lightweight source client that pushes MP3 files to Icecast

### Installation Steps Icecast

Run `icecast.sh`, which:

1. Installs dependencies
2. Builds and configures Icecast
3. Automatically executes `ezstream_install.sh` to install and configure Ezstream

After setup, the system will:

- Start Icecast on port 8000
- Start streaming a sample MP3 using Ezstream

### Access Icecast

```bash
http://<your-pi-ip>:8000/test
```

### Restart Stream

```bash
killall ezstream && /opt/ezstream/bin/ezstream -c ~/ezstream-test/ezstream-minimal.xml &
```

## Configuration Details

### Icecast Settings

- **Max Clients**: 100 concurrent connections
- **Max Sources**: 2 simultaneous streams
- **Authentication**:
  - Admin access control
  - Source client authentication
- **Log Storage**: `/opt/icecast/var/log/icecast`

### Ezstream Settings

- **Operation Mode**: Continuous loop playback
- **Supported Format**: MP3 files
- **Configuration File**: `~/ezstream-test/ezstream-minimal.xml`

---

## Performance Considerations

### Raspberry Pi Capabilities

- **Recommended Listeners**: 12-20 concurrent streams
- **Network Considerations**: Home network bandwidth limitations

### Scaling Options

1. **Horizontal Scaling**:
   - Deploy multiple Icecast servers
   - Implement load balancing

2. **Vertical Scaling**:
   - Upgrade CPU resources
   - Increase network bandwidth

3. **Alternative Solutions**:
   - Implement MPD as streaming source
   - Consider cloud hosting for larger deployments

---

## Alternative Option: MPD (Music Player Daemon)

### Key Features

- Multi-format audio support (MP3, FLAC, OGG, etc.)
- Flexible streaming options:
  - Direct to Icecast servers
  - Local network playback
- Remote control capabilities:
  - Dedicated client apps
  - Web interfaces
  - Command line control

---

## Implementation Notes

### System Requirements

- **Supported OS**: Debian-based distributions (Raspbian, Ubuntu, etc.)
- **Network Requirements**:
  - Stable internet connection
  - Open ports (default: 8000 for Icecast)
  - Port forwarding for external access

### Customization

- Configuration files can be modified for:
  - Different port assignments
  - Custom authentication
  - Alternative storage locations
- Scripts can be extended to include:
  - Automatic playlist generation
  - Scheduled streaming
  - Remote management features

### Maintenance

- Regular log rotation recommended
- Monitor system resources during peak usage
- Keep system packages updated for security
