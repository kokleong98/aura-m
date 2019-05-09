#!/bin/bash
####################  DO NOT REMOVE THESE LINES #################### 
# VERSION=0.1.0 
# FILENAME=update-auram.sh
# DESCRIPTION=AURA-M update version services script
####################################################################

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
auram stop

sudo rm ~/.auram/start-auram.sh ~/.auram/stop-auram.sh 

curl -O https://raw.githubusercontent.com/kokleong98/aura-m/master/install-auram.sh
chmod +x install-auram.sh
sudo ./install-auram.sh
