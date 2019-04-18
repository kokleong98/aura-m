#!/bin/bash
####################  DO NOT REMOVE THESE LINES #################### 
# VERSION=0.1.0 
# FILENAME=install-auram.sh
# DESCRIPTION=AURA-M Main installation script
#################################################################### 
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
license=$(curl -s https://raw.githubusercontent.com/kokleong98/aura-m/master/LICENSE)
echo -e "\e[1;33m$license\e[0m"
read -p "Do you accept the license agreement? (y/n) " accept

if [ accept != 'y' ]; then
  echo "Aborting installation."
  exit 0
fi

#########################################
# 1. Deploying aura componenets
#########################################
read -p "Enter new user account: " username

Inst_Count=$(dpkg -s apt-transport-https ca-certificates curl software-properties-common docker-compose build-essential python npm | grep "Status: install ok installed" -c)

if [ $Inst_Count -ne 8 ]
  sudo chmod +x add-aura.sh
  echo "Start Deploy aura."
  "${DIR}/add-aura.sh" $username
  exitcode=$?

  if [ $exitcode -ne 0 ]; then
    echo "Deploy aura failed."
    exit exitcode
  else
    echo "Deploy aura success."
  fi
else
  echo "Aura dependencies existed. Skip aura installation."
  group="docker"
  user=$username
  result=$(awk -v group=$group -v user=$user -F':' '{if($1 == group && $4 == user) print $4}' /etc/group)
  if [ "$result" != "$username" ]; then
    echo "Adding $username to group $group."
    sudo usermod -aG sudo $username
    if [ $? -ne 0 ]
    then
      echo "Fail to add $username to group $group. Abort installation."
      exit 1
    else
      echo "Added $username to group $group sucessfully."
    fi
  else
    echo "$username already belongs to group $group."
  fi
fi

