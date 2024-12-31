#!/bin/bash

# Execute the setup script to create .terraformrc
/usr/local/bin/setup_terraformrc.sh

# Execute the script to copy and fix permissions for SSH keys
/usr/local/bin/setup_ssh_keys.sh

# Execute the main command passed to the container
exec "$@"
