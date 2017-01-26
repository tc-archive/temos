#!/bin/bash -e

echo "Installing core image components..."

# Updating and Upgrading dependencies
sudo apt-get update -y -qq > /dev/null
sudo apt-get upgrade -y -qq > /dev/null

export DEBIAN_FRONTEND="noninteractive"

# Install necessary libraries for guest additions and Vagrant NFS Share
sudo -E apt-get -y -q install linux-headers-$(uname -r) build-essential dkms nfs-common

# Install necessary dependencies
# sudo apt-get -y -q install curl wget git tmux firefox xvfb vim gpg rvm
sudo -E apt-get -y -q install curl wget git tmux vim gpg

# Setup sudo to allow no-password sudo for "admin"
groupadd -r admin
usermod -a -G admin vagrant
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers
