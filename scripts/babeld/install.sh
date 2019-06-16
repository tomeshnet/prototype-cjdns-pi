#!/bin/bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#Enable test repo
echo deb deb http://meshwithme.online/deb/repos/apt/debian stretch main | sudo tee /etc/apt/sources.list.d/tomesh.list

sudo apt-get update
sudo apt-get install babeld
