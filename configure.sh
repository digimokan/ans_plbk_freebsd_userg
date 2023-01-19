#!/bin/sh
./third_party/ans_bootstrap_run_playbook/configure.sh \
  --root-playbook-dir="${PWD}" \
  --ansible-packages-list="sysutils/ansible python" \
  --download-and-update-roles \
  --roles-dir="${PWD}/roles/ext" \
  --run-playbook \
  "${@}"

