inspect_args
ansible-playbook playbooks/init_control_plane.yaml \
  --private-key "~/.ssh/k8s.leonid.sh" \
  -e "public_ipv6=$arg_public_ipv6 internal_ipv4=$arg_internal_ipv4 hostname=$arg_hostname"
