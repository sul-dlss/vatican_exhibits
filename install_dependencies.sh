#!/bin/bash

# Echo the commands as they run
set -x #echo on

# Update and clean packages
yum clean all
yum check-update
yum update --verbose

# Install EPEL (needed for Redis and Passenger)
yum install -y epel-release yum-utils
yum-config-manager --enable epel
yum update -y

# Install which / needed for RVM install
yum install -v -y which

# Install RVM
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh
rvm install 2.5.1

# Set the user that will be running the app to the rvm group
usermod -aG rvm centos

# Install Java 10
yum install -y java-1.8.0-openjdk-headless

# Install initscripts / service
yum install -y initscripts

# Install Solr
curl -O http://apache.claz.org/lucene/solr/7.3.0/solr-7.3.0.tgz 
tar xzf solr-7.3.0.tgz solr-7.3.0/bin/install_solr_service.sh --strip-components=2
bash ./install_solr_service.sh solr-7.3.0.tgz

# Install ImageMagick
yum install -y ImageMagick ImageMagick-devel

# Install Redis
yum install -y redis

# Install Apache HTTP
yum install -y httpd
systemctl enable httpd.service

# Install Passenger (with ntp dependency)
yum install -y ntp
chkconfig ntpd on
ntpdate pool.ntp.org

yum install -y pygpgme curl
curl --fail -sSLo /etc/yum.repos.d/passenger.repo https://oss-binaries.phusionpassenger.com/yum/definitions/el-passenger.repo
yum install -y mod_passenger || yum-config-manager --enable cr && yum install -y mod_passenger
systemctl restart httpd
/usr/bin/passenger-config validate-install --auto

# Make user directory where app is served from executable
chmod +x /home/centos/

# Configure passenger
echo "

<VirtualHost *:80>
    PassengerRuby /usr/local/rvm/gems/ruby-2.5.1/wrappers/ruby
    DocumentRoot /home/centos/vatican_exhibits/public
    PassengerStickySessions on

    <Directory /home/centos/vatican_exhibits/public>
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

# Install Git
yum install -y git

# Set a secret env for Rails
echo "
export SECRET_KEY_BASE=`tr -cd '[:alnum:]' < /dev/urandom | fold -w128 | head -n1`
" >> /etc/profile.d/rails.sh

chmod +x /etc/profile.d/rails.sh

exit 0
