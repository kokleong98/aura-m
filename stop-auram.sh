#!/bin/bash
####################  DO NOT REMOVE THESE LINES #################### 
# VERSION=0.1.0 
# FILENAME=stop-auram.sh
# DESCRIPTION=AURA-M Systemd service stop script
####################################################################
source /home/##username##/.nvm/nvm.sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -f "${DIR}/auram.detach" ]; then
  echo "Aura monitor detached."
else
  idex stop
fi
