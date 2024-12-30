inspect_args
ansible-playbook playbooks/join_ctrl.yaml \
  --private-key "~/.ssh/k8s.leonid.sh" \
  -e "public_ipv6=$arg_public_ipv6 internal_ipv4=$arg_internal_ipv4 hostname=$arg_hostname existing_ctrl_public_ipv6=$arg_existing_ctrl_public_ipv6"
