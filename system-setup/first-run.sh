#!/bin/bash
mysql -e "CREATE USER '$MYSQL_USER'@localhost IDENTIFIED BY '$MYSQL_PASSWORD'"
mysql -e "GRANT ALL ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@localhost ;"
mysql -e "CREATE DATABASE \`exhibits-prod\`;"

# TODO: Configure a new solr collection
su -c "/opt/solr/bin/solr create -c blacklight-core -d /home/centos/vatican_exhibits/current/solr/conf -p 8983" -m "solr"

ntpdate pool.ntp.org

# Create seeded user
echo "
user = Spotlight::Engine.user_class.find_or_create_by!(email: 'test@example.com') do |u|
  u.password = 'password'
end
Spotlight::Role.create(user: user, resource: Spotlight::Site.instance, role: 'admin')
" >> db/seeds.rb

su -m "centos" -c "cd /home/centos/vatican_exhibits/current;
bin/rails db:create;
bin/rails db:migrate;
bin/rails db:seed"
