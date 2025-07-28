#!/bin/bash
set -e

# Detecteer juiste gebruiker (ook als script via sudo wordt uitgevoerd)
ICECAST_USER=${SUDO_USER:-$(whoami)}
ICECAST_GROUP=$(id -gn "$ICECAST_USER")

echo "==> Installeren van build tools en libraries voor icecast..."
sudo apt update
sudo apt install -y build-essential git pkg-config \
  libxml2-dev libxslt1-dev libvorbis-dev libogg-dev \
  libtheora-dev libcurl4-openssl-dev libssl-dev \
  libtool automake autoconf yasm libshout3-dev libmp3lame-dev libspeex-dev

echo "==> Icecast broncode downloaden..."
mkdir -p ~/src/icecast
cd ~/src/icecast
git clone https://gitlab.xiph.org/xiph/icecast-server.git
cd icecast-server
git checkout v2.4.4

echo "==> Bouwen van Icecast..."
./autogen.sh
./configure --prefix=/opt/icecast
make -j"$(nproc)"
sudo make install

echo "==> Maken van logdirectory..."
sudo mkdir -p /opt/icecast/var/log/icecast
sudo chown -R "$ICECAST_USER:$ICECAST_GROUP" /opt/icecast/var

echo "==> Systemd unit schrijven..."
UNIT_FILE="/etc/systemd/system/icecast.service"
sudo tee "$UNIT_FILE" > /dev/null <<EOF
[Unit]
Description=Icecast Streaming Server
After=network.target

[Service]
Type=simple
ExecStart=/opt/icecast/bin/icecast -c /opt/icecast/etc/icecast.xml
Restart=on-failure
User=$ICECAST_USER
Group=$ICECAST_GROUP
ProtectSystem=full
ProtectHome=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

echo "==> Systemd herladen en inschakelen..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable icecast
sudo systemctl start icecast


echo "Icecast instellen..."

ICECAST_CONF_DIR="/opt/icecast/etc"
ICECAST_CONF_FILE="$ICECAST_CONF_DIR/icecast.xml"
ICECAST_IP=$(hostname -I | awk '{print $1}')
SOURCE_PASS="stream123"
ADMIN_PASS="beheer456"
PIDFILE="/opt/icecast/var/icecast.pid"

echo "==> Schrijft minimale icecast.xml naar: $ICECAST_CONF_FILE"

cat <<EOF | sudo tee "$ICECAST_CONF_FILE" > /dev/null
<icecast>
  <location>Raspberry Pi</location>
  <admin>admin@$ICECAST_IP</admin>
  <hostname>$ICECAST_IP</hostname>

  <limits>
    <clients>100</clients>
    <sources>2</sources>
    <queue-size>524288</queue-size>
    <client-timeout>30</client-timeout>
    <header-timeout>15</header-timeout>
    <source-timeout>10</source-timeout>
    <burst-on-connect>1</burst-on-connect>
    <burst-size>65535</burst-size>
  </limits>

  <authentication>
    <source-password>$SOURCE_PASS</source-password>
    <relay-password>relay123</relay-password>
    <admin-user>admin</admin-user>
    <admin-password>$ADMIN_PASS</admin-password>
  </authentication>

  <listen-socket>
    <port>8000</port>
  </listen-socket>

  <paths>
    <logdir>/opt/icecast/var/log/icecast</logdir>
    <webroot>/opt/icecast/share/icecast/web</webroot>
    <adminroot>/opt/icecast/share/icecast/admin</adminroot>
    <pidfile>$PIDFILE</pidfile>
    <alias source="/" destination="/status.xsl"/>
  </paths>

  <logging>
    <accesslog>access.log</accesslog>
    <errorlog>error.log</errorlog>
    <loglevel>3</loglevel>
    <logsize>10000</logsize>
  </logging>

  <security>
    <chroot>0</chroot>
  </security>

  <fileserve>1</fileserve>

  <http-headers>
    <header name="Access-Control-Allow-Origin" value="*" />
  </http-headers>

  <alias source="/" destination="/status.xsl"/>
</icecast>
EOF

echo "Icecast.xml gegenereerd met IP: $ICECAST_IP:8000"

echo "Icecast is geïnstalleerd en gestart."

echo "==> Ezstream installatie script starten..."
chmod +x ~/ezstream_install.sh
bash ~/ezstream_install.sh



