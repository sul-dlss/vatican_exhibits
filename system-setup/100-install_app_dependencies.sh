#!/bin/bash

# Echo the commands as they run
set -x #echo on

# Download repository from GitHub
cd /srv/app
git clone https://github.com/sul-dlss/vatican_exhibits.git current --depth=0
cd current

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
