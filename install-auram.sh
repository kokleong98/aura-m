#!/bin/bash
####################  DO NOT REMOVE THESE LINES #################### 
# VERSION=0.1.0 
# FILENAME=install-auram.sh
# DESCRIPTION=AURA-M Main installation script
#################################################################### 
license=$(curl -s https://raw.githubusercontent.com/kokleong98/aura-m/master/LICENSE)
echo -e "\e[1;33m$license\e[0m"
read -p "Do you accept the license agreement? (y/n) " accept

if [ accept != 'y' ]; then
  echo "Aborting installation."
  exit 0
fi

read -p "Enter new user account: " username
sudo chmod +x add-aura.sh
echo "Start Deploy aura."
add-aura.sh $username
exitcode=$?

if [ $exitcode -ne 0 ]; then
  echo "Deploy aura failed."
  exit exitcode
else
  echo "Deploy aura success."
fi
