#!/bin/sh

################################################################################
# purpose:   update all system config with ansible
# args/opts: see usage (run with -h option)
################################################################################

# User Selection Options
ugrade_ansible_packages='false'

print_usage() {
  echo 'USAGE:'
  echo "  $(basename "${0}")  -h"
  echo "  $(basename "${0}")  [-u]"
  echo 'OPTIONS:'
  echo '  -h, --help'
  echo '      print this help message'
  echo '  -u, --upgrade-ansible-packages'
  echo '      upgrade ansible (required for initial run, and after sys upgrades)'
  echo 'EXIT CODES:'
  echo '    0  ok'
  echo '    1  usage, arguments, or options error'
  echo '    5  ansible upgrade error'
  echo '   10  ansible role or playbook error'
  echo '  255  unknown error'
  exit "${1}"
}

get_cmd_opts() {
  while getopts ':hu-:' option; do
    case "${option}" in
      h)  handle_help ;;
      u)  handle_upgrade_ansible_packages ;;
      -)  case ${OPTARG} in
            help)                          handle_help ;;
            help=*)                        handle_illegal_option_arg "${OPTARG}" ;;
            upgrade-ansible-packages)      handle_upgrade_ansible_packages ;;
            upgrade-ansible-packages=*)    handle_illegal_option_arg "${OPTARG}" ;;
            '')                            break ;; # non-option arg starting with '-'
            *)                             handle_unknown_option "${OPTARG}" ;;
          esac ;;
      \?) handle_unknown_option "${OPTARG}" ;;
    esac
  done
}

handle_help() {
  print_usage 0
}

handle_upgrade_ansible_packages() {
  ugrade_ansible_packages='true'
}

handle_unknown_option() {
  err_msg="unknown option \"${1}\""
  quit_err_msg_with_help "${err_msg}" 1
}

handle_illegal_option_arg() {
  err_msg="illegal argument in \"${1}\""
  quit_err_msg_with_help "${err_msg}" 1
}

print_err_msg() {
  echo 'ERROR:'
  printf "$(basename "${0}"): %s\\n\\n" "${1}"
}

quit_err_msg_with_help() {
  print_err_msg "${1}"
  print_usage "${2}"
}

do_ugrade_ansible_packages() {
  pkg install --yes sysutils/ansible python
  exit_code="${?}"
  if [ "${exit_code}" != 0 ]; then
    quit_err_msg_with_help "error attempting to upgrade ansible" 5
  fi
}

download_roles_and_collections() {
  # use ansible-galaxy cmd to download roles & collections from github/galaxy/etc
  ansible-galaxy install \
    --role-file requirements.yml \
    --roles-path ./roles/ext \
    --force-with-deps
  exit_code="${?}"
  if [ "${exit_code}" != 0 ]; then
    quit_err_msg_with_help "error attempting to download roles and collections" 10
  fi
}

run_playbook() {
  # run the playbook, passing through args to ansible-playbook cmd
  ansible-playbook -i hosts --ask-become-pass --become-method=su playbook.yml
  exit_code="${?}"
  if [ "${exit_code}" != 0 ]; then
    quit_err_msg_with_help "error attempting to run playbook" 10
  fi
}

main() {
  get_cmd_opts "$@"
  if [ "${ugrade_ansible_packages}" = 'true' ]; then
    do_ugrade_ansible_packages "$@"
  fi
  download_roles_and_collections "$@"
  run_playbook "$@"
  exit 0
}

main "$@"

