#!/bin/bash

mkdir -p /root/.ssh

# Copy all files from the mounted directory into .ssh
# (keys, known_hosts, etc. if they exist)
cp -r /root/.mounted_ssh/* /root/.ssh/ 2>/dev/null || true

# Secure directory and file permissions
chmod 700 /root/.ssh
chown root:root /root/.ssh

# - Private key(s) -> 600
# - Public key(s)  -> 644
find /root/.ssh -type f -exec chmod 600 {} \;
find /root/.ssh -type f -name '*.pub' -exec chmod 644 {} \;

# Ensure ownership is root:root
chown -R root:root /root/.ssh

echo "SSH keys have been copied and secured."
