inspect_args

public_ipv6="${args['--public-ipv6']}"
internal_ipv4="${args['--internal-ipv4']}"
hostname="${args['--hostname']}"
existing_ctrl_public_ipv6="${args['--existing-ctrl-public-ipv6']}"

echo "Debugging Arguments:"
echo "Public IPv6: $public_ipv6"
echo "Internal IPv4: $internal_ipv4"
echo "Hostname: $hostname"
echo "Existing Control Plane IPv6: $existing_ctrl_public_ipv6"

ansible-playbook playbooks/join_worker.yaml \
  --private-key "~/.ssh/k8s.leonid.sh" \
  -e "public_ipv6=$public_ipv6 \
      internal_ipv4=$internal_ipv4 \
      hostname=$hostname \
      existing_ctrl_public_ipv6=$existing_ctrl_public_ipv6 \
      ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'"
