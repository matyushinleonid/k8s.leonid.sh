#!/bin/bash

# Input: Space-separated list of worker IPs
input="$1"
IFS=' ' read -r -a worker_ips <<< "$input"

# Debug input
echo "DEBUG: Input received: '$input'" >&2
echo "DEBUG: Parsed worker_ips: ${worker_ips[*]}" >&2

# Validate input
if [ ${#worker_ips[@]} -eq 0 ]; then
  echo "Error: No worker IPs provided."
  exit 1
fi

# Base HAProxy configuration (global and defaults sections)
cat <<EOF
global
    log /dev/log    local0
    log /dev/log    local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

    # Default SSL material locations
    ca-base /etc/ssl/certs
    crt-base /etc/ssl/private

    # See: https://ssl-config.mozilla.org/#server=haproxy&server-version=2.0.3&config=intermediate
    ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
    ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
    ssl-default-bind-options ssl-min-ver TLSv1.2 no-tls-tickets

defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    timeout connect 5000
    timeout client  50000
    timeout server  50000
    errorfile 400 /etc/haproxy/errors/400.http
    errorfile 403 /etc/haproxy/errors/403.http
    errorfile 408 /etc/haproxy/errors/408.http
    errorfile 500 /etc/haproxy/errors/500.http
    errorfile 502 /etc/haproxy/errors/502.http
    errorfile 503 /etc/haproxy/errors/503.http
    errorfile 504 /etc/haproxy/errors/504.http

frontend http
    bind *:80
    bind :::80
    default_backend k8s_nodes_http

frontend https
    bind *:443
    bind :::443
    mode tcp
    default_backend k8s_nodes_https

backend k8s_nodes_http
    balance roundrobin
    option httpchk GET /
    http-check expect status 404
EOF

# Add server lines for each worker IP
for i in "${!worker_ips[@]}"; do
  ip="${worker_ips[$i]}"
  # Validate IP format (basic validation for IPv4)
  if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    echo "    server node$i $ip:32616 check"
  else
    echo "Warning: Skipping invalid IP: $ip" >&2
  fi
done

cat <<'EOF'

backend k8s_nodes_https
    mode tcp
    balance roundrobin
EOF

# Append worker servers for HTTPS backend (port 30620)
for i in "${!worker_ips[@]}"; do
  ip="${worker_ips[$i]}"
  if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    echo "    server node$i $ip:30620 check"
  else
    echo "Warning: Skipping invalid IP: $ip" >&2
  fi
done