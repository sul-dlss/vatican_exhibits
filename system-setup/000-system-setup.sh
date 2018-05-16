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

# Install Java 10
yum install -y java-1.8.0-openjdk-headless

# Install initscripts / service
yum install -y initscripts
