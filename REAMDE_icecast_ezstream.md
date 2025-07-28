# Icecast + Ezstream Streaming Server Setup

This project sets up an Icecast streaming server with Ezstream as a source client on a Raspberry Pi (or similar Linux system). It allows you to stream audio over your local network and listen via a browser or media players.

---

## Overview

- **Icecast**: An open-source streaming media server that serves audio streams to listeners.
- **Ezstream**: A lightweight client that sends audio streams (sources) to the Icecast server.
- **Setup**: Two scripts, `icecast.sh` and `ezstream_install.sh`, automate the installation and configuration.
- **Purpose**: Provide a simple and customizable streaming solution on a Raspberry Pi, supporting multiple streams and clients.

---

## Prerequisites

- A Raspberry Pi or Linux machine with network access.
- Basic command-line knowledge.
- `icecast.sh` and `ezstream_install.sh` scripts placed in your home directory (`~/`).

---

## Installation

1. Make `icecast.sh` executable and run it:

   ```bash
   chmod +x ~/icecast.sh
   ./icecast.sh

  
- The `icecast.sh` script:
  - Installs dependencies.
  - Builds Icecast from source.
  - Sets up and configures the Icecast service.
  - Automatically runs `ezstream_install.sh`.

- The `ezstream_install.sh` script:
  - Installs Ezstream from source.
  - Sets up a test audio stream.
  - Starts streaming to the Icecast server.

---

## Usage

- Once both scripts finish, your Icecast server will be running and streaming a sample audio file.
- To listen to the stream, open a browser or audio player and visit:

http://<your-pi-ip>:8000/test

Replace `<your-pi-ip>` with the IP address displayed by the script at the end of the setup.

- To restart the stream later, run:

```bash
killall ezstream && /opt/ezstream/bin/ezstream -c ~/ezstream-test/ezstream-minimal.xml &
## Technical Details

### Icecast

- Icecast serves audio streams over HTTP to any client that supports streaming.
- Configured to listen on port 8000.
- Configuration includes:
  - Maximum 100 clients.
  - Maximum 2 source streams.
  - Authentication passwords for source and admin access.
- Logs are stored under `/opt/icecast/var/log/icecast`.

### Ezstream

- Acts as the source client that pushes audio files to Icecast.
- Configured via an XML file (`ezstream-minimal.xml`).
- Streams a local MP3 file continuously with `stream_once` enabled.

---

## Scalability and Listener Capacity

- A Raspberry Pi can comfortably support around 12-20 concurrent listeners on a typical home network.
- Icecast supports multiple streams and multiple clients per stream.
- For increased listener capacity or more streams, consider:
  - Load balancing across multiple Icecast servers.
  - Upgrading hardware or network bandwidth.
  - Using advanced streaming setups with multiple source clients.

---

## Alternative: MPD (Music Player Daemon)

- MPD is a flexible, networked music player.
- It can be used as a source client streaming to Icecast or as a standalone local music server.
- Advantages:
  - Supports multiple audio formats and output plugins.
  - Remote control via various clients.
  - Suitable for both simple playback and advanced streaming setups.
- MPD is compatible with most platforms and can be easily integrated into this setup if desired.

