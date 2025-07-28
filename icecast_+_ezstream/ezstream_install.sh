#!/bin/bash
set -e

echo "==> Installeren van build tools en afhankelijkheden..."
sudo apt update
sudo apt install -y build-essential git pkg-config \
  libxml2-dev libxslt1-dev libvorbis-dev libogg-dev \
  libtheora-dev libcurl4-openssl-dev libssl-dev \
  libtool automake autoconf yasm \
  libshout3-dev libmp3lame-dev libspeex-dev \
  gettext libtool-bin dh-autoreconf check libtagc0-dev

echo "==> Broncode van Ezstream downloaden..."
mkdir -p ~/src/ezstream
cd ~/src/ezstream

if [ ! -d "ezstream" ]; then
  git clone https://gitlab.xiph.org/xiph/ezstream.git
else
  echo "Ezstream-directory bestaat al, overslaan van clone..."
fi

cd ezstream

echo "==> Build voorbereiden met autotools..."
aclocal
autoreconf -fiv

echo "==> Configureren..."
./configure --prefix=/opt/ezstream

echo "==> Bouwen..."
make -j"$(nproc)"

echo "==> Installeren naar /opt/ezstream..."
sudo make install

echo "==> Toevoegen van /opt/ezstream/bin aan PATH (indien nodig)..."
if ! grep -q '/opt/ezstream/bin' <<< "$PATH"; then
  if ! grep -q '/opt/ezstream/bin' ~/.bashrc; then
    echo 'export PATH=/opt/ezstream/bin:$PATH' >> ~/.bashrc
    echo "-> Pad toegevoegd aan ~/.bashrc"
  fi
  export PATH=/opt/ezstream/bin:$PATH
  echo "-> Pad toegevoegd aan huidige shellsessie"
else
  echo "-> Pad is al aanwezig in PATH"
fi

echo "==> Installatie afgerond."
/opt/ezstream/bin/ezstream -V || echo "Waarschuwing: ezstream lijkt niet correct geïnstalleerd."

# === TESTCONFIGURATIE ===

echo "==> Ezstream testconfiguratie opzetten..."

MUSIC_DIR="$HOME/ezstream-test"
mkdir -p "$MUSIC_DIR"
cd "$MUSIC_DIR"

# Samplebestand downloaden
if [ ! -f "$MUSIC_DIR/audio.mp3" ]; then
    echo "Downloading sample music file..."
    curl -L -o "$MUSIC_DIR/audio.mp3" 'https://docs.google.com/uc?export=download&id=1kjHk-m0vD6T0s33CaQFBvULRWhkCQ0nD'
else
    echo "Sample music file already exists. Skipping download."
fi

# Configbestand aanmaken
cat > "$MUSIC_DIR/ezstream-minimal.xml" <<EOF
<ezstream>
  <servers>
    <server>
      <hostname>127.0.0.1</hostname>
      <port>8000</port>
      <password>stream123</password>
    </server>
  </servers>

  <streams>
    <stream>
      <mountpoint>/test</mountpoint>
      <format>MP3</format>
    </stream>
  </streams>

  <intakes>
    <intake>
      <filename>$MUSIC_DIR/audio.mp3</filename>
      <stream_once>1</stream_once>
      <encode>0</encode>
    </intake>
  </intakes>
</ezstream>
EOF

# Controleren of Icecast draait
echo "==> Icecast status controleren..."
if pgrep -x icecast2 > /dev/null; then
    echo "Icecast draait."
else
    echo "Icecast draait niet! Start deze handmatig of via een apart script."
fi

# Stream starten
echo "==> Starten van teststream met Ezstream..."
/opt/ezstream/bin/ezstream -c "$MUSIC_DIR/ezstream-minimal.xml" &

# IP ophalen en luister-url tonen
LOCAL_IP=$(hostname -I | awk '{print $1}')
echo ""
echo "===================================================="
echo "Stream actief!"
echo "Luister via: http://$LOCAL_IP:8000/test"
echo "Je kunt dit openen in een browser of audioplayer."
echo "===================================================="
echo ""
echo "Om de stream opnieuw te starten, gebruik:"
echo "killall ezstream && /opt/ezstream/bin/ezstream -c \"$MUSIC_DIR/ezstream-minimal.xml\" &"
echo ""
