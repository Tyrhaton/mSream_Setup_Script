#!/bin/bash

# STEP 1: update and install dependencies

apt update && apt upgrade -y

sudo apt-get install\
 git \
 g++ \
 cmake \
 libboost-program-options-dev \
 libboost-system-dev \
 libavutil-dev \
 libavformat-dev \
 libstb-dev \
 libconfig++-dev \
 ffmpeg \
 libtag1-dev \
 libpam0g-dev \
 libgtest-dev \
 libarchive-dev \
 libxxhash-dev \
 libboost-iostreams-dev \
 libboost-filesystem-dev \
 libboost-thread-dev \
 libgraphicsmagick++1-dev \
 libpstreams-dev \
 ffmpeg \
 build-essential pkg-config \
 libssl-dev zlib1g-dev \
 -y

# STEP 2: Install WT from source
cd ~
git clone https://github.com/emweb/wt.git
cd wt
mkdir build && cd build
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr/local
make -j$(nproc)
sudo make install
sudo ldconfig

# STEP 3: Install LMS from source
cd ~
git clone https://github.com/epoupon/lms.git
cd lms
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_UNITY_BUILD=ON -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=TRUE -DCMAKE_INSTALL_PREFIX=/usr
make -j$(nproc)
sudo make install

# STEP 4: Configure LMS

sudo cp /usr/share/lms/lms.conf /etc/lms.conf
sudo cp /usr/share/lms/default.service /lib/systemd/system/lms.service

sudo groupadd --system lms
sudo useradd  --system \
              --no-create-home \
              --gid lms \
              --shell /usr/sbin/nologin \
              lms
sudo mkdir -p /var/lms
sudo chown -R lms:lms /var/lms

# STEP 5: Add music to test LMS

sudo mkdir -p /usr/music
sudo curl -L -o "audio.mp3" 'https://docs.google.com/uc?export=download&id=1kjHk-m0vD6T0s33CaQFBvULRWhkCQ0nD'

# STEP 6: Start LMS

sudo systemctl enable lms
sudo systemctl start lms

# STEP 7: Visit webpage
ip addr show wlan0
# http://192.168.2.30:5082