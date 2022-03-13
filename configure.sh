#!/bin/sh

# use ansible-galaxy cmd to download roles & collections from github/galaxy/etc
ansible-galaxy install \
  --role-file requirements.yml \
  --roles-path ./roles/ext \
  --force-with-deps \
  || exit 1

# run the playbook, passing through args to ansible-playbook cmd
ansible-playbook -i hosts --ask-become-pass --become-method=su "${@}" playbook.yml

