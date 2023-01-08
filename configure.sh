#!/bin/sh

################################################################################
# purpose:   update all system config with ansible
# args/opts: see usage (run with -h option)
################################################################################

# User Selection Options
ugrade_ansible_packages='false'

# Hard-Coded Selections
bootstrap_packages='sysutils/ansible python'

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

try_with_exit() {
  cmd="${1}"
  err_msg="${2}"
  err_code="${3}"
  echo "Executing cmd: '${cmd}'..."
  eval "${cmd}"
  exit_code="${?}"
  if [ "${exit_code}" != 0 ]; then
    quit_err_msg_with_help "${err_msg}" "${err_code}"
  fi
}

get_sudo_root_passwd_from_user() {
  # get the root password at command line
  stty -echo
  printf "Enter sudo (root) password: " >&2
  read -r sudo_root_password
  stty echo

  # invoke all cmds *other than ansible-playbook* with sudo
  if [ "$(id -un)" = 'root' ]; then
    cmd_prefix=''
  else
    cmd_prefix="echo ${sudo_root_password} | sudo -S "
  fi
}

do_ugrade_ansible_packages() {
  try_with_exit \
    "${cmd_prefix}pkg install --yes ${bootstrap_packages}" \
    "error attempting to upgrade ansible" 5
}

download_roles_and_collections() {
  # use ansible-galaxy cmd to download roles & collections from github/galaxy/etc
  try_with_exit \
    "${cmd_prefix}ansible-galaxy install --role-file requirements.yml --roles-path ./roles/ext --force-with-deps" \
    "error attempting to download roles and collections" 10
}

run_playbook() {
  # run the playbook, passing through args to ansible-playbook cmd
  try_with_exit \
    "ansible-playbook -i hosts --become-method=su --extra-vars='ansible_become_password=${sudo_root_password}' playbook.yml" \
    "error attempting to run playbook" 10
}

main() {
  get_cmd_opts "$@"
  get_sudo_root_passwd_from_user "$@"
  if [ "${ugrade_ansible_packages}" = 'true' ]; then
    do_ugrade_ansible_packages "$@"
  fi
  download_roles_and_collections "$@"
  run_playbook "$@"
  exit 0
}

main "$@"

