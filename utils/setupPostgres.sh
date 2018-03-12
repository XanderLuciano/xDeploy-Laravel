#!/bin/bash

# Check if root
# To run command as current user: sudo -u $curr_user
if ! [ $(id -u) = 0 ]; then
   echo "Server Setup needs to be run as root." >&2
   exit 1
else
    curr_user=$(who am i | awk '{print $1}')
fi

echo "We will now go through a basic setup for PostgreSQL!"
echo "When the prompt appears, run the following commands:"
echo "createuser --interactive --pwprompt"
echo "createdb DATABASENAME"
echo "when finished, simply input: \q"

sudo -u postgres psql

echo "That's it! Feel free to re-run this utility if you need to create a new user / db"