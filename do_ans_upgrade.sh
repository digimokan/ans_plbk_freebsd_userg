#!/bin/sh
# Purpose: update ansible to latest python version on FreeBSD

# FreeBSD ansible won't auto-update to latest pyXX-ansible version, so do this
echo "Installing the latest 'pyXX-ansible' package...."
pkg install --yes sysutils/ansible

