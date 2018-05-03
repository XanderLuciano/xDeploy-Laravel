# Utility Scripts

These utility scripts provided enhanced server setup options and automation. They are not only used for setup, but some can also be used for server modification.

## Virtualhost.sh

This script allows you to easily create and destory virtualhost files for Nginx.

Usage:

```$ sudo bash /path/to/virtualhost.sh [ create | delete ] [ domain ] [optional: root-directory]```

Where `domain` is the URL of your website and `root-directory` is the path to the public folder.

## setupSSL.sh

This script allows you to easily add an SSL certificate to a domain.

Usage:

```$ sudo bash setupSSL.sh```

This command just runs certbot, so certbot will prompt you for everything needed.
