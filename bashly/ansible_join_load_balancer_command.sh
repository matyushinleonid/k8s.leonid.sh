inspect_args

public_ipv6="${args['--public-ipv6']}"
internal_ipv4="${args['--internal-ipv4']}"
hostname="${args['--hostname']}"
existing_ctrl_public_ipv6="${args['--existing-ctrl-public-ipv6']}"
worker_internal_ipv4="${args['--worker-internal-ipv4']}"

echo "Debugging Arguments:"
echo "Public IPv6: $public_ipv6"
echo "Internal IPv4: $internal_ipv4"
echo "Hostname: $hostname"
echo "Existing Control Plane IPv6: $existing_ctrl_public_ipv6"
echo "Worker IP(s) for HAProxy: $worker_internal_ipv4"

ansible-playbook playbooks/join_load_balancer.yaml \
  --private-key "~/.ssh/k8s.leonid.sh" \
  -e "public_ipv6=$public_ipv6 \
      internal_ipv4=$internal_ipv4 \
      hostname=$hostname \
      existing_ctrl_public_ipv6=$existing_ctrl_public_ipv6 \
      worker_internal_ipv4='$worker_internal_ipv4' \
      ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'"
