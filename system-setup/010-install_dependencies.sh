#!/bin/bash

# Echo the commands as they run
set -x #echo on

# Install Solr
tar xzf solr-7.3.0.tgz solr-7.3.0/bin/install_solr_service.sh --strip-components=2
bash ./install_solr_service.sh solr-7.3.0.tgz -n

# Set the user that will be running the app to the solr group
usermod -aG solr centos
chmod g+w /var/solr/data

# Install ImageMagick
yum install -y ImageMagick ImageMagick-devel

# Install Redis
yum install -y redis
systemctl enable redis.service

# Install Apache HTTP
yum install -y httpd
systemctl enable httpd.service

# Install Passenger (with ntp dependency)
yum install -y ntp
chkconfig ntpd on

yum install -y pygpgme curl
curl --fail -sSLo /etc/yum.repos.d/passenger.repo https://oss-binaries.phusionpassenger.com/yum/definitions/el-passenger.repo
yum install -y mod_passenger || yum-config-manager --enable cr && yum install -y mod_passenger

# Configure passenger
echo "

<VirtualHost *:80>
    PassengerRuby /usr/local/rvm/gems/ruby-2.5.1/wrappers/ruby
    DocumentRoot /srv/app/current/public
    PassengerStickySessions on

    <Directory /srv/app/current/public>
        Allow from all
        Options -MultiViews
        Require all granted
    </Directory>
</VirtualHost>
" >> /etc/httpd/conf.modules.d/10-passenger.conf

# Install nodejs
curl --silent --location https://rpm.nodesource.com/setup_8.x | bash -
yum install -y nodejs

# Install MariaDB
yum install -y mariadb-server mariadb-devel
systemctl enable mariadb.service

MYSQL_DATABASE=exhibits-prod
MYSQL_USER=exhibits
MYSQL_PASSWORD=`tr -cd '[:alnum:]' < /dev/urandom | fold -w128 | head -n1`

# Install Git
yum install -y git
yum install -y sudo
# Set the Rails env
echo "export RAILS_ENV=production" >> /etc/profile.d/rails.sh

# Set database env variables
echo "
export MYSQL_DATABASE=$MYSQL_DATABASE
export MYSQL_USER=$MYSQL_USER
export MYSQL_PASSWORD=$MYSQL_PASSWORD
export DATABASE_URL=mysql2://$MYSQL_USER:$MYSQL_PASSWORD@localhost/$MYSQL_DATABASE
" >> /etc/profile.d/rails.sh

# Set a secret env for Rails
echo "
export SECRET_KEY_BASE=`tr -cd '[:alnum:]' < /dev/urandom | fold -w128 | head -n1`
" >> /etc/profile.d/rails.sh

chmod +x /etc/profile.d/rails.sh

mkdir /srv/app
chown centos /srv/app

exit 0
