#!/bin/bash
# entrypoint.sh

# Execute the setup script to create .terraformrc
/usr/local/bin/setup_terraformrc.sh

# Execute the main command passed to the container
exec "$@"
