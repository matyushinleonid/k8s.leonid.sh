#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check if TERRAFORM_CLOUD_TOKEN is set
if [ -z "$TERRAFORM_CLOUD_TOKEN" ]; then
  echo "TERRAFORM_CLOUD_TOKEN is not set. Skipping .terraformrc creation."
  exit 0
fi

# Determine the home directory; default to /root if HOME is not set
HOME_DIR=${HOME:-/root}

# Define the path to the .terraformrc file
TERRAFORM_RC_FILE="$HOME_DIR/.terraformrc"

# Create the .terraformrc file with the Terraform Cloud token
cat <<EOF > "$TERRAFORM_RC_FILE"
credentials "app.terraform.io" {
  token = "$TERRAFORM_CLOUD_TOKEN"
}
EOF

# Set appropriate permissions for the .terraformrc file
chmod 600 "$TERRAFORM_RC_FILE"

echo ".terraformrc file created successfully at $TERRAFORM_RC_FILE."
