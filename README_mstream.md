# mSream_Setup_Script
![Version](https://img.shields.io/badge/version-1.0.0-green.svg)

A script to automatically setup mStream onto a Linux based Operating system like a Raspberry Pi 4b.

# Dependencies:

 - [mStream](https://github.com/IrosTheBeggar/mStream) mStream is a personal music streaming server. You can use mStream to stream your music from your home computer to any device, anywhere.

# Setup Instructions
## Option 1: Run from local PC
1. Download this whole repository.
2. Run `/secure_copy_and_run.sh`.
3. Enter the servers `username`.
4. Enter the servers `Hostname` or `IP`.
5. Enter if you want NodeJS to be build from source (enter `N` for fast download).

## Option 2: Run from server
1. Download `./script.sh` into your server.
2. Run `./script.sh run` (You can add `-source` to build from source) 
3. After instalation, view the music server at `http://localhost:3030`

# Usage
- Start the server using `./script.sh start`.
- You can upload any music (.mp3) files you want into `/home/<USER>/music/`.

# Access
- Visit the music server at `http://<IP_ADDRESS>:3030`.

