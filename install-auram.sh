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

if [ "$accept" != "y" ]; then
  echo "Aborting installation."
  exit 0
fi

function GetGitDependency()
{
  filename="$1"
  if [ ! -f "${DIR}/$filename" ]; then
    echo "Downloading $filename."
    curl -O "https://raw.githubusercontent.com/kokleong98/aura-m/master/$filename"
    ret="$?"
    if [ $ret -ne 0 ]; then
      echo "Fail to download https://raw.githubusercontent.com/kokleong98/aura-m/master/$filename."
      return $ret
    fi
  fi
  sudo chmod +x "${DIR}/$filename"
  return 0
}

function GetAccountDependency()
{
  group="$1"
  user="$2"
  result=$(groups "$user" | grep -e " $group " -e " $group$")
  if [ "$result" != "$user" ]; then
    echo "Adding $user to group $group."
    sudo usermod -aG sudo $user
    if [ $? -ne 0 ];
    then
      echo "Fail to add $user to group $group. Abort installation."
      return 1
    else
      echo "Added $user to group $group sucessfully."
      return 0
    fi
  else
    echo "$user already belongs to group $group."
    return 0
  fi
}

#########################################
# 1. Deploying aura componenets
#########################################
read -p "Enter new user account: " username

Inst_Count=$(dpkg -s apt-transport-https ca-certificates curl software-properties-common docker-compose build-essential python npm | grep "Status: install ok installed" -c)

if [ $Inst_Count -ne 8 ]; then
  GetGitDependency "add-aura.sh"
  if [ $? -ne 0 ]; then
    echo "Fail to get git file add-aura.sh depedency. Abort installation."
    exit 1
  fi
  echo "Start Deploy aura."
  "${DIR}/add-aura.sh" $username
  exitcode=$?

  if [ $exitcode -ne 0 ]; then
    echo "Deploy aura failed."
    exit exitcode
  else
    echo "Deploy aura success."
  fi
  echo "Aura dependencies existed. Skip aura installation."
fi

GetAccountDependency "docker" "$username"
if [ $? -ne 0 ]; then
  echo "Fail to add account $username to group docker depedency."
  exit 1
fi
GetAccountDependency "sudo" "$username"
if [ $? -ne 0 ]; then
  echo "Fail to add account $username to group docker depedency."
  exit 1
fi

#########################################
# 2. Check and prepare AURA-M scripts.
#########################################
GetGitDependency "start-auram.sh"
if [ $? -ne 0 ]; then
  echo "Fail to get git file start-auram.sh depedency. Abort installation."
  exit 1
fi
GetGitDependency "stop-auram.sh"
if [ $? -ne 0 ]; then
  echo "Fail to get git file stop-auram.sh depedency. Abort installation."
  exit 1
fi
GetGitDependency "add-auram-service.sh"
if [ $? -ne 0 ]; then
  echo "Fail to get git file add-auram-service.sh depedency. Abort installation."
  exit 1
fi

"${DIR}/add-auram-service.sh" "$username" "$DIR"
