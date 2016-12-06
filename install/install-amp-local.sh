#!/bin/bash

# Stop script on error
set -e

# Clone AMP Vagrant repo
git clone https://github.com/cloudsoft/amp-vagrant
cd amp-vagrant

# Replace servers.yaml file
mv servers.yaml servers.yaml.bak
curl -k -O https://raw.githubusercontent.com/cloudsoft/brooklyn-hyperledger/master/servers.yaml

# Launch AMP and BYON Vagrant VMs
vagrant up
