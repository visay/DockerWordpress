#!/bin/bash

# Exit with error if a command returns a non-zero status
set -e
# wrapper command to fix the permission
sudo -E -u guest /var/www/vendor/bin/wp $*
