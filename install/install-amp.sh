#!/bin/bash

# Stop script on error
set -e

# Clone AMP Vagrant repo
git clone https://github.com/cloudsoft/amp-vagrant
cd amp-vagrant

# Launch AMP Vagrant VM
vagrant up amp
