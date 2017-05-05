#!/bin/bash

# Exit with error if a command returns a non-zero status
set -e
cd /var/www/web
# wrapper command to fix the permission
sudo -E -u guest /var/www/vendor/bin/wp $*
