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

# Commands: setup, vhost [args]
command=$1

# 
if [ "$command" != 'setup' ] && [ "$command" != 'vhost' ]; then
	echo -e $"Invalide choice.\nPlease choose either setup or vhost"
	exit 1;
fi


