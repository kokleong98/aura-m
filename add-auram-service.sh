#!/bin/bash
####################  DO NOT REMOVE THESE LINES #################### 
# VERSION=0.1.0 
# FILENAME=install-auram.sh
# DESCRIPTION=AURA-M systemd service installation script
####################################################################
if [ $# -lt 1 ]
  echo "Insufficient parameters."
  exit 1
fi
username="$1"
DIR="$2"

if [ -z "$DIR" ]; then
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi
#########################################
# 4. Create AURA-M systemd service file
#########################################
cat > aura-m.service << EOF
[Unit]
Description=AURA-M monitoring service

[Service]
User=$username
WorkingDirectory=/home/$username/
ExecStart=${DIR}/start-auram.sh
ExecStop=${DIR}/stop-auram.sh
Restart=on-failure
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF

sudo mv aura-m.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable aura-m.service
