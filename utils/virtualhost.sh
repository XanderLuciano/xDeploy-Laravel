#!/bin/bash

# Check if root
# To run command as current user: sudo -u $curr_user
if ! [ $(id -u) = 0 ]; then
   echo "Server Setup needs to be run as root." >&2
   exit 1
else
    curr_user=$(who am i | awk '{print $1}')
fi

# Source: https://github.com/RoverWire/virtualhost
# usage: sudo sh virtualhost.sh [ create | delete ] [ domain ] [ optional: rootDirectory ]
# ex: sudo virtualhost create dev.mysite.com dev/mysite/public

# Set Language
TEXTDOMAIN=virtualhost

# Set default parameters
action=$1
domain=$2
rootDir=$3
owner=$(who am i | awk '{print $1}')
sitesEnable='/etc/nginx/sites-enabled/'
sitesAvailable='/etc/nginx/sites-available/'
userDir='/srv/www'

if [ "$(whoami)" != 'root' ]; then
	echo $"You have no permission to run $0 as non-root user. Use sudo"
		exit 1;
fi

if [ "$action" != 'create' ] && [ "$action" != 'delete' ]
	then
		echo $"You need to prompt for action (create or delete) -- Lower-case only"
		exit 1;
fi

while [ "$domain" == "" ]
do
	echo -e $"Please provide domain. e.g.dev,staging"
	read domain
done

if [ "$rootDir" == "" ]; then
	rootDir=${domain//./}
fi

### if root dir starts with '/', don't use /srv/www as default starting point
if [[ "$rootDir" =~ ^/ ]]; then
	userDir=''
fi

rootDir=$userDir$rootDir

if [ "$action" == 'create' ]
	then
		# Check if domain already exists
		if [ -e $sitesAvailable$domain ]; then
			echo -e $"This domain already exists.\nPlease Try Another one"
			exit;
		fi

		# Check if directory exists
		if ! [ -d $userDir$rootDir ]; then
			
			# Create the directory
			mkdir $userDir$rootDir
			
			# Set directory permissions
			chmod 755 $userDir$rootDir
			
			# Write test file in the new domain dir
			if ! echo "<?php echo phpinfo(); ?>" > $userDir$rootDir/phpinfo.php
				then
					echo $"ERROR: Not able to write in file $userDir/$rootDir/phpinfo.php. Please check permissions."
					exit;
			else
					echo $"Added content to $userDir$rootDir/phpinfo.php."
			fi
		fi

		# Create virtual host
		if ! echo 
"server {
	listen 80;
	listen [::]:80;
	
	server_name $domain;
	
	root $userDir$rootDir;
	
	index index.php index.html index.htm;
	
	location / {
		try_files $uri $uri/ /index.php?$query_string;
	}
	
	# removes trailing slashes (prevents SEO duplicate content issues)
	if (!-d \$request_filename) {
		rewrite ^/(.+)/\$ /\$1 permanent;
	}
	
	# unless the request is for a valid file (image, js, css, etc.), send to bootstrap
	#if (!-e \$request_filename) {
	#	rewrite ^/(.*)\$ /index.php?/\$1 last;
	#	break;
	#}
	
	# removes trailing 'index' from all controllers
	#if (\$request_uri ~* index/?\$) {
	#	rewrite ^/(.*)/index/?\$ /\$1 permanent;
	#}
	
	# catch all
	location ~ \.php$ {
		try_files \$uri /index.php =404;
		fastcgi_split_path_info ^(.+\.php)(/.+)\$;
		#fastcgi_pass 127.0.0.1:9000;
		fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
		fastcgi_index index.php;
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		include fastcgi_params;
	}
	
	location ~ /\.ht {
		deny all;
	}
}" > $sitesAvailable$domain

	then
			echo -e $"There was an error creating the $domain file."
			exit;
		else
			echo -e $"\nNew Virtual Host Created!\n"
		fi

		if [ "$owner" == "" ]; then
			chown -R $(whoami):www-data $userDir$rootDir
		else
			chown -R $owner:www-data $userDir$rootDir
		fi

		# Enable website
		ln -s $sitesAvailable$domain $sitesEnable$domain

		# Restart Nginx
		service nginx restart

		# Show the finished message
		echo -e $"Complete! \nYou now have a new Virtual Host \nYour new host is: http://$domain \nAnd its located at $userDir$rootDir"
		exit;
	else
		# Check whether domain already exists
		if ! [ -e $sitesAvailable$domain ]; then
			echo -e $"This domain dont exists.\nPlease Try Another one"
			exit;
		else
			# Delete domain in /etc/hosts
			newhost=${domain//./\\.}
			sed -i "/$newhost/d" /etc/hosts

			# Disable website
			rm $sitesEnable$domain

			# Restart Nginx
			service nginx restart

			# Delete virtual host rules files
			rm $sitesAvailable$domain
		fi

		# Check if directory exists or not
		if [ -d $userDir$rootDir ]; then
			echo -e $"Delete host root directory ? (s/n)"
			read deldir

			if [ "$deldir" == 's' -o "$deldir" == 'S' ]; then
				# Delete the directory
				rm -rf $userDir$rootDir
				echo -e $"Directory deleted"
			else
				echo -e $"Host directory conserved"
			fi
		else
			echo -e $"Host directory not found. Ignored"
		fi

		# End of Script
		echo -e $"Complete!\nYou just removed Virtual Host $domain"
		exit 0;
fi