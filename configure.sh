#!/bin/sh
./third_party/ans_bootstrap_run_playbook/configure.sh \
  --root-playbook-dir="." \
  --ansible-packages-list="sysutils/ansible python" \
  --download-and-update-roles \
  --roles-dir="./roles/ext" \
  --run-playbook \
  "${@}"

