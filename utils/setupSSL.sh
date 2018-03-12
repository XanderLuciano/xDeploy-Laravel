#!/bin/bash

# Check if root
# To run command as current user: sudo -u $curr_user
if ! [ $(id -u) = 0 ]; then
   echo "Server Setup needs to be run as root." >&2
   exit 1
else
    curr_user=$(who am i | awk '{print $1}')
fi

echo "Firing up certbot to create an SSL cert through Let's Encrypt"

certbot

echo "Certbot completed."