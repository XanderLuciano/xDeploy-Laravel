#!/bin/bash

# Note: to change user password - sudo passwd USERNAME

# Check if root
# To run command as current user: sudo -u $curr_user
if ! [ $(id -u) = 0 ]; then
   echo "Server Setup needs to be run as root." >&2
   exit 1
else
    curr_user=$(who am i | awk '{print $1}')
fi

# Set colors so we can spice up the console
NC='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

echo -e "${Green}Starting up!${NC} - Running as: ${Cyan}${curr_user}"

# Update Package List and Packages
echo -e "${Cyan}Updating packages${NC}"
apt-get update > /dev/null
apt-get -y upgrade > /dev/null

# Set Timezone
echo -e "${Blue}Setting timezone to Cali${NC}"
timedatectl set-timezone US/Pacific

# Add Custom Repos
echo -e "${Cyan}Adding Repos${NC}"
apt-add-repository ppa:ondrej/php -y > /dev/null
add-apt-repository ppa:certbot/certbot -y > /dev/null

# Update Repos
apt-get update > /dev/null

# Install Common Utilities
echo -e "${Cyan}Installing Stuff from repos${NC}"
apt-get install openssl zip unzip git software-properties-common -y > /dev/null

# Install Server Utilities - nginx, postgresql, certbot, php
apt-get install nginx postgresql python-certbot-nginx -y > /dev/null
apt-get install php php-common php-fpm php-pgsql php-mbstring php-mcrypt php-gd php-zip php-xml php-json php-cli php-curl -y > /dev/null

# Clean up packages
echo -e "${Cyan}Cleaning up packages.${NC}"
apt-get autoremove -y > /dev/null

# Install composer
echo -e "${Green}Installing Composer${NC}"
sudo -u $curr_user cd ~
sudo -u $curr_user curl -s http://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Install Laravel
echo -e "${Yellow}Installing Laravel${NC}"
sudo -u $curr_user composer global require "laravel/installer"

# Install Node.js & NPM
echo -e "${Green}Installing Node.js and npm${NC}"
sudo -u $curr_user cd ~
sudo -u $curr_user curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash -
apt-get install -y nodejs

# Install Deployer
echo -e "${Green}Installing Deployer${NC}"
sudo -u $curr_user cd ~
sudo -u $curr_user curl -LO https://deployer.org/deployer.phar
mv deployer.phar /usr/local/bin/dep
chmod +x /usr/local/bin/dep

# Finished Setting up server
echo -e "${Green}Setup Finished!${NC}"
