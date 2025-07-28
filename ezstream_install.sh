#!/bin/bash
set -e

echo "==> Installing build tools and dependencies..."
sudo apt update
sudo apt install -y build-essential git pkg-config \
  libxml2-dev libxslt1-dev libvorbis-dev libogg-dev \
  libtheora-dev libcurl4-openssl-dev libssl-dev \
  libtool automake autoconf yasm \
  libshout3-dev libmp3lame-dev libspeex-dev \
  gettext libtool-bin dh-autoreconf check libtagc0-dev

echo "==> Downloading Ezstream source code..."
mkdir -p ~/src/ezstream
cd ~/src/ezstream

if [ ! -d "ezstream" ]; then
  git clone https://gitlab.xiph.org/xiph/ezstream.git
else
  echo "Ezstream directory already exists, skipping clone..."
fi

cd ezstream

echo "==> Preparing build with autotools..."
aclocal
autoreconf -fiv

echo "==> Configuring..."
./configure --prefix=/opt/ezstream

echo "==> Building..."
make -j"$(nproc)"

echo "==> Installing to /opt/ezstream..."
sudo make install

echo "==> Adding /opt/ezstream/bin to PATH (if needed)..."
if ! grep -q '/opt/ezstream/bin' <<< "$PATH"; then
  if ! grep -q '/opt/ezstream/bin' ~/.bashrc; then
    echo 'export PATH=/opt/ezstream/bin:$PATH' >> ~/.bashrc
    echo "-> Path added to ~/.bashrc"
  fi
  export PATH=/opt/ezstream/bin:$PATH
  echo "-> Path added to current shell session"
else
  echo "-> Path is already present in PATH"
fi

echo "==> Installation completed."
/opt/ezstream/bin/ezstream -V || echo "Warning: ezstream does not seem to be installed correctly."

# === TEST CONFIGURATION ===

echo "==> Setting up Ezstream test configuration..."

MUSIC_DIR="$HOME/ezstream-test"
mkdir -p "$MUSIC_DIR"
cd "$MUSIC_DIR"

# Download sample file
if [ ! -f "$MUSIC_DIR/audio.mp3" ]; then
    echo "Downloading sample music file..."
    curl -L -o "$MUSIC_DIR/audio.mp3" 'https://docs.google.com/uc?export=download&id=1kjHk-m0vD6T0s33CaQFBvULRWhkCQ0nD'
else
    echo "Sample music file already exists. Skipping download."
fi

# Create config file
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

# Check if Icecast is running
echo "==> Checking Icecast status..."
if pgrep -x icecast2 > /dev/null; then
    echo "Icecast is running."
else
    echo "Icecast is not running! Start it manually or via a separate script."
fi

# Start streaming
echo "==> Starting test stream with Ezstream..."
/opt/ezstream/bin/ezstream -c "$MUSIC_DIR/ezstream-minimal.xml" &

# Get local IP and show listening URL
LOCAL_IP=$(hostname -I | awk '{print $1}')
echo ""
echo "===================================================="
echo "Stream is active!"
echo "Listen via: http://$LOCAL_IP:8000/test"
echo "You can open this in a browser or audio player."
echo "===================================================="
echo ""
echo "To restart the stream, use:"
echo "killall ezstream && /opt/ezstream/bin/ezstream -c \"$MUSIC_DIR/ezstream-minimal.xml\" &"
echo ""

