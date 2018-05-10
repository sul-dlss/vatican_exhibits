#!/bin/bash

# Echo the commands as they run
set -x #echo on

# Download repository from GitHub
cd /home/centos
git clone https://github.com/sul-dlss/vatican_exhibits.git --depth=0
cd vatican_exhibits

# Use 2.5.1 as default
source /etc/profile.d/rvm.sh
rvm --default use 2.5.1

# Install Ruby dependencies
gem install bundler
bundle install --deployment

# Setup database
RAILS_ENV=production bin/rails db:create
RAILS_ENV=production bin/rails db:migrate

exit 0
