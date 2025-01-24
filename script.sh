#!/bin/bash

# Zorg dat het script stopt bij fouten
set -e

sudo su

echo "Setup script voor mStream music server gestart..."

# Controleer of het script met rootrechten wordt uitgevoerd
if [ "$EUID" -ne 0 ]; then
  echo "Voer dit script uit met sudo of als root."
  exit 1
fi

# Update systeem en installeer vereiste pakketten
echo "Updaten en installeren van vereiste pakketten..."
apt update && apt upgrade -y
apt install -y git nodejs npm ffmpeg

# Clone de mStream-repository
echo "Clonen van de mStream-repository..."
BASE_DIR="/home/rpi/mStream"
if [ -d "$BASE_DIR" ]; then
  echo "Directory $BASE_DIR bestaat al. Verwijderen..."
  rm -rf "$BASE_DIR"
fi
git clone https://github.com/IrosTheBeggar/mStream.git "$BASE_DIR"

# Ga naar de directory en installeer afhankelijkheden
cd "$BASE_DIR"
echo "Installeren van afhankelijkheden en configureren..."

# muziek conf
mkdir /home/rpi/muziek

#download music
curl -L -o /home/rpi/muziek/audio.mp3 'https://docs.google.com/uc?export=download&id=1kjHk-m0vD6T0s33CaQFBvULRWhkCQ0nD'


CONFIG_DIR="/home/rpi/mStream/save/conf"

# Maak de map als deze niet bestaat
if [ ! -d "$CONFIG_DIR" ]; then
  echo "Maken van configuratiemap: $CONFIG_DIR"
  mkdir -p "$CONFIG_DIR"
fi

# Maak het config.json-bestand
echo "Schrijven van config.json naar $CONFIG_DIR"
cat <<EOL > "/home/rpi/mStream/save/conf/config.json"
{
  "port": 3030,
  "secret": "b6j7j5e6u5g36ubn536uyn536unm5m67u5365vby435y54ymn",
  "folders": {
    "muziek": { 
        "root": "/home/rpi/muziek"
        }
  },
  "users": {}
}
EOL

echo "Configuratiebestand succesvol aangemaakt!"

# go to the servers folder
cd /home/rpi/mStream

# install dependencies
npm install

# npm run-script wizard -j /home/rpi/mStream/save/conf/config.json
sudo node cli-boot-wrapper.js -j /home/rpi/mStream/save/conf/config.json

# Maak een README.md
echo "Maken van README.md..."
cat <<EOL > "$BASE_DIR/README.md"
# mStream Music Server
Deze server maakt gebruik van de mStream-software om muziek te streamen vanaf een Raspberry Pi.

## Installatie
1. Voer \`run_os.sh\` uit.
2. Configureer mStream tijdens de wizard.

## Gebruik
- Start de server via \`npm start\` in de map \`$BASE_DIR\`.
- Upload je muziekbestanden naar de gewenste directory.

## Toegang
- Bezoek de server via \`http://<pi_ip>:3000\`.

Voor meer informatie zie de officiële [mStream-documentatie](https://github.com/IrosTheBeggar/mStream).
EOL

echo "Setup voltooid! Ga naar $BASE_DIR en start de server met \`npm start\`."
