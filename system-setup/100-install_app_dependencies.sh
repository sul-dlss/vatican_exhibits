#!/bin/bash

# Echo the commands as they run
set -x #echo on

# Download repository from GitHub
cd /srv/app
mkdir releases
mkdir shared
mkdir -p shared/log shared/tmp/pids shared/tmp/cache shared/tmp/sockets

git clone https://github.com/sul-dlss/vatican_exhibits.git releases/0 --depth=0
ln -s /srv/app/releases/0 /srv/app/current
cd /srv/app/current
rm -rf /srv/app/current/log; ln -s /srv/app/shared/log /srv/app/current/log
ln -s /srv/app/shared/tmp/* /srv/app/current/tmp

# Use 2.5.1 as default
source /etc/profile.d/rvm.sh
rvm --default use 2.5.1

# Install Ruby dependencies
gem install bundler
bundle install --deployment

source /etc/profile.d/rails.sh

# Precompile javascript + css assets
# Note: our current context doesn't have access to the database)
(unset DATABASE_URL; bundle exec rake assets:precompile)

exit 0
