# ans_plbk_freebsd_userg

Ansible playbook to configure a NUC6I7KYK with FreeBSD and i3wm.

[![Release](https://img.shields.io/github/release/digimokan/ans_plbk_freebsd_userg.svg?label=release)](https://github.com/digimokan/ans_plbk_freebsd_userg/releases/latest "Latest Release Notes")
[![License](https://img.shields.io/badge/license-MIT-blue.svg?label=license)](LICENSE.md "Project License")

## Table Of Contents

* [Purpose](#purpose)
* [Hardware Parts List](#hardware-parts-list)
* [NUC6I7KYK BIOS Configuration](#nuc6i7kyk-bios-configuration)
* [Quick Start](#quick-start)
    * [Install Base System](#install-base-system)
    * [Configure Workstation](#configure-workstation)
    * [Update Workstation](#update-workstation)
* [Vault Variables](#vault-variables)
* [Source Code Layout](#source-code-layout)
* [Integration Tests](#integration-tests)
* [Contributing](#contributing)

## Purpose

Set up a workstation/desktop-PC on a [NUC6I7KYK](https://www.intel.com/content/www/us/en/products/sku/89187/intel-nuc-kit-nuc6i7kyk/specifications.html)
for normal daily use, for one user:

* Install FreeBSD on two mirrored hard drives.
* Configure the [i3wm](https://i3wm.org/) window manager.
* Configure a basic set of desktop applications.
* Configure a set of applications for software development.

## Hardware Parts List

* [Intel NUC6I7KYK Bare Bones Kit](https://www.amazon.com/gp/product/B01DJ9XS52):
  for main PC kit.
* [Monoprice 1 ft 3-Prong AC Power Cord](https://www.amazon.com/Monoprice-18AWG-Grounded-Power-IEC-320-C5/dp/B08BXM5CGB):
  since NUC6I7KYK Bare Bones Kit DC adapter is missing this part.
* [Crucial 32GB DDR4 RAM](https://www.amazon.com/gp/product/B015YPB8ME):
  for two 16GB RAM boards.
* [Samsung 970 EVO Plus NVMe M.2 2TB SSD, x 2](https://www.amazon.com/gp/product/B07MFZXR1B):
  for two mirrored hard drives.
* [HP Pavilion 22CWA 21.5 in 1080p IPS LED Monitor](https://www.amazon.com/dp/B015WCV70W):
  connected to rear HDMI port.
* [Logitech Z207 Powered Speakers](https://www.amazon.com/dp/B074KJ6JQW):
  for main desktop sound, connected to rear 3.5 mm input jack.
* [Cable Matters Ultra Mini 4 Port USB 3.0 Hub, x 2](https://www.amazon.com/dp/B00PHPWLPA):
  for two hubs, each connected to a rear USB 3.0 port.
* [eMeet USB Speakerphone](https://www.amazon.com/dp/B07Q3D7F8S):
  to provide mic + speaker for video-conferencing and recording, connected to
  rear USB Hub.
* [Logitech C920e Webcam (Mic-Disabled)](https://www.amazon.com/dp/B08CS18WVP):
  for camera-input only (mic-disabled, to declutter sound panel selections),
  connected to rear USB Hub.

## NUC6I7KYK BIOS Configuration

* Press F7 at BIOS screen to update BIOS firmware:
    * Update to Version 0074 (29 OCT 2021), with
      [file KY0074.bio](https://www.intel.com/content/www/us/en/download/18677/bios-update-kyskli70.html).
* Press F2 at BIOS screen, and go to Devices Tab:
    * Disable 'Thunderbolt Controller.'
    * Disable 'WLAN.'
    * Disable 'Bluetooth.'
    * Disable 'Enhanced Consumer IR.'

## Quick Start

### Install Base System

1. Download the latest _RELEASE_ installer image for _amd64_ ("disc1") on the
   [FreeBSD Download Page](https://www.freebsd.org/where/).

2. Write the installer image to a USB stick, as described in
   [FreeBSD Handbook Installation Chapter](https://docs.freebsd.org/en/books/handbook/bsdinstall/#bsdinstall-pre).

3. Insert the USB stick into the target workstation PC, and boot from the
   FreeBSD installer image.

4. Follow guided installation. Select/enable __only__ these options:

    * Host Name: _userg.machine_.
    * Optional system components: none.
    * zfs guided installation: _mirror_ (for 2 disks), and enable _encrypt disks_.
    * Network interface _em0_: enable _IPv4_, and enable _dhcp_.
    * Install services: _ntpd_, _ntpdate_.

5. Remove the USB stick, and reboot the PC to the new installation.

### Configure Workstation

1. Install _git_ package at the root prompt:

   ```shell
   $ pkg install git
   ```

2. Clone project into a local project directory:

   ```shell
   $ git clone --recurse-submodules https://github.com/digimokan/ans_plbk_freebsd_userg.git
   ```

3. Change to the local project directory:

   ```shell
   $ cd ans_plbk_freebsd_userg
   ```

4. Ensure `vault_password.txt` has been created, as desribed in
   [Vault Variables](#vault-variables).

5. Run the [`configure.sh`](../configure.sh) script to configure the workstation.

   ```shell
   $ ./configure.sh -u
   ```
   _NOTE: -u option required for initial run, and after system/package updates._

### Update Workstation

To update the workstation PC at a later time, use the `admin` user account, which
was set up during initial configuration.

1. Log in to the `admin` user account.

2. Change to the pre-provisioned project directory:

   ```shell
   $ cd ans_plbk_freebsd_userg
   ```

3. Optionally, pull in changes to this playbook and its submodules:

   ```shell
   $ git pull --ff-only --recurse-submodules
   ```

4. Run the [`configure.sh`](../configure.sh) script to update the workstation.

   ```shell
   $ ./configure.sh
   ```

## Vault Variables

* The encrypted vault variables are stored in [`vault.yml`](../host_vars/vault.yml).

* Prior to encrypting or decrypting vault variables, the vault password string
  needs to be put into the `vault_password.txt` file
  ([at the root of this repo directory](#source-code-layout)).

* [`playbook.yml`](../playbook.yml) automatically uses the vault password file to
  decrypt vars in [`vault.yml`](../host_vars/vault.yml), via a setting in
  [`ansible.cfg`](../ansible.cfg).

* [`playbook.yml`](../playbook.yml) uses the proxy vars in
  [`vars.yml`](../host_vars/vars.yml), which point to encrypted vars in
  [`vault.yml`](../host_vars/vault.yml).

* To start, encrypt a plaintext-edited vault.yml file:

   ```shell
   $ ansible-vault encrypt host_vars/vault.yml
   ```

* Once vault.yml has been encrypted, do edits/updates in place:

   ```shell
   $ ansible-vault edit host_vars/vault.yml
   ```

* To view the vault.yml vars in read-only mode:

   ```shell
   $ ansible-vault view host_vars/vault.yml
   ```

## Source Code Layout

```
├─┬ ans_plbk_freebsd_userg/
│ │
│ ├─┬ host_vars/
│ │ │
│ │ └── vars.yml          # proxy vars used by playbook, point to vault.yml vars
│ │ └── vault.yml         # encrypted vault variables used by playbook.yml
│ │
│ ├─┬ roles/
│ │ │
│ │ └── ext/              # external (third-party, downloaded) roles
│ │
│ ├── ansible.cfg         # play-wide Ansible meta-config
│ ├── configure.sh        # configures the workstation, post-installation
│ ├── hosts               # Ansible inventory (configured for local host)
│ ├── playbook.yml        # main Ansible playbook
│ ├── requirements.yml    # list of roles (on github/galaxy) to download
│ └── vault_password.txt  # password-string to encrypt and decrypt vault vars
│
```

## Integration Tests

* Play a video in browser(s).
* Check builtin headphone jack on speakers.
* Check microphone input in browser(s): https://www.onlinemictest.com/.
* Check webcam in browser(s): https://www.onlinemictest.com/webcam-test/.
* Check mic and webcam in a google meeting.
* Check mic and webcam in a zoom meeting.
* Print a web page to the printer(s).
* Print a text document to the printer(s).
* Print a PDF document to the printer(s).
* Scan a color image to the scanner(s).
* Scan a text document to the scanner(s).
* List, check, and delete an overnight backup.
* In OBS, record a video with mic and webcam.
* In OBS, record a video with mic and screen capture.
* Check USB storage drive insertion and removal.

## Contributing

* Feel free to report a bug or propose a feature by opening a new
  [Issue](https://github.com/digimokan/ans_plbk_freebsd_userg/issues).
* Follow the project's [Contributing](CONTRIBUTING.md) guidelines.
* Respect the project's [Code Of Conduct](CODE_OF_CONDUCT.md).

