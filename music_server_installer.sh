#!/bin/bash

# Make all scripts executable
chmod +x icecast.sh lms.sh mstream.sh music_server_installer.sh

echo "Choose a music server to run:"
echo "1) Icecast"
echo "2) LMS"
echo "3) MStream"

read -p "Enter your choice (1-3): " choice

case $choice in
  1)
    ./icecast.sh
    ;;
  2)
    ./lms.sh
    ;;
  3)
    ./mstream.sh
    ;;
  *)
    echo "Invalid choice."
    exit 1
    ;;
esac

