inspect_args

public_ipv6="${args['--public-ipv6']}"
internal_ipv4="${args['--internal-ipv4']}"
hostname="${args['--hostname']}"

echo "Debugging Arguments:"
echo "Public IPv6: $public_ipv6"
echo "Internal IPv4: $internal_ipv4"
echo "Hostname: $hostname"

ansible-playbook playbooks/init_control_plane.yaml \
  --private-key "~/.ssh/k8s.leonid.sh" \
  -e "public_ipv6=$public_ipv6 \
      internal_ipv4=$internal_ipv4 \
      hostname=$hostname \
      ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'"
