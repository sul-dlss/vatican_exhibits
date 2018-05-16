#!/bin/bash
set -x #echo on

# Install which / needed for RVM install
yum install -v -y which

# Install RVM
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh
rvm install 2.5.1

# Set the user that will be running the app to the rvm group
usermod -aG rvm centos
