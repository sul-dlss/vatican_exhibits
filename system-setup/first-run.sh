#!/bin/bash

# NOTE: This script needs to be run once within the container; it executes
# steps that need to happen after system services are running.

# Configure a new solr collection
su -c "/opt/solr/bin/solr create -c blacklight-core -d /srv/app/current/solr/config -p 8983" -m "solr"

# Update the current date+time
ntpdate pool.ntp.org

# Create and configure a new database
mysql -e "CREATE USER '$MYSQL_USER'@localhost IDENTIFIED BY '$MYSQL_PASSWORD'"
mysql -e "GRANT ALL ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@localhost ;"
mysql -e "CREATE DATABASE \`$MYSQL_DATABASE\`;"

# Create seeded user
echo "
user = Spotlight::Engine.user_class.find_or_create_by!(email: 'test@example.com') do |u|
  u.password = 'password'
end
Spotlight::Role.create(user: user, resource: Spotlight::Site.instance, role: 'admin')
" >> /srv/app/current/db/seeds.rb

# Populate the database
su -m "centos" -c "cd /srv/app/current;
bin/rails db:create;
bin/rails db:migrate;
bin/rails db:seed"
