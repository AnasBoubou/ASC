#!/bin/bash

IP=$(cd ../; tofu output -raw instance_ip 2>/dev/null)

if [ -z "$IP" ] || [[ "$IP" == *"No outputs"* ]]; then
    echo '{"all": {"hosts": []}}'
    exit 0
fi

cat <<EOF
{
  "all": {
    "hosts": ["$IP"],
    "vars": {
      "ansible_user": "ubuntu",
      "ansible_ssh_private_key_file": "~/.ssh/id_rsa"
    }
  }
}
EOF
