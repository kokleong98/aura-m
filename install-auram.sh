#!/bin/bash
####################  DO NOT REMOVE THESE LINES #################### 
# VERSION=0.1.0 
# FILENAME=install-auram.sh
# DESCRIPTION=AURA-M Main installation script
#################################################################### 

function ShowWarning()
{
  echo -e "\e[1;33m$1\e[0m"
}

function ShowSuccess()
{
  echo -e "\e[1;32m$1\e[0m"
}

function ShowError()
{
  echo -e "\e[1;31m$1\e[0m"
}

function ShowAction()
{
  echo -e "\e[1;36m$1\e[0m"
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
license=$(curl -s https://raw.githubusercontent.com/kokleong98/aura-m/master/LICENSE)
ShowWarning "$license"
read -p "Do you accept the license agreement? (y/n) " accept

if [ "$accept" != "y" ]; then
  ShowError "Aborting installation."
  exit 0
fi


function GetGitDependency()
{
  filename="$1"
  path="$2"
  if [ ! -f "$path/$filename" ]; then
    ShowAction "Downloading $filename."
    curl "https://raw.githubusercontent.com/kokleong98/aura-m/master/$filename" > "$path/$filename"
    ret="$?"
    if [ $ret -ne 0 ]; then
      ShowError "Fail to download https://raw.githubusercontent.com/kokleong98/aura-m/master/$filename."
      return $ret
    fi
  fi
  if [ -z "$3" ]; then
    sudo chmod +x "$path/$filename"
  fi
  if [ ! -z "$4" ]; then
    sudo chown "$4" "$path/$filename"
  fi
  return 0
}

function GetAccountDependency()
{
  group="$1"
  user="$2"
  result=$(groups "$user" | grep -e " $group " -e " $group$" -c)
  if [ "$result" -eq 0 ]; then
    ShowAction "Adding $user to group $group."
    sudo usermod -aG $group $user
    if [ $? -ne 0 ];
    then
      ShowError "Fail to add \e[1;41m$user\e[1;31m to group \e[1;41m$group\e[1;31m. Abort installation."
      return 1
    else
      ShowSuccess "Added \e[1;42m$user\e[1;32m to group \e[1;42m$group\e[1;32m sucessfully."
      return 0
    fi
  else
    ShowWarning "\e[1;41m$user\e[1;31m already belongs to group \e[1;41m$group\e[1;31m."
    return 0
  fi
}

#################################################################### 
# 1. Deploying aura componenets
#################################################################### 
read -p "Enter new user account: " username

Inst_Count=$(dpkg -s apt-transport-https ca-certificates curl software-properties-common docker-compose build-essential python npm | grep "Status: install ok installed" -c)

if [ $Inst_Count -ne 8 ]; then
  GetGitDependency "add-aura.sh" "$DIR"
  if [ $? -ne 0 ]; then
    ShowError "Fail to get git file add-aura.sh depedency. Abort installation."
    exit 1
  fi
  ShowAction "Start Deploy aura."
  "${DIR}/add-aura.sh" $username
  exitcode=$?

  if [ $exitcode -ne 0 ]; then
    ShowError "Deploy aura failed."
    exit exitcode
  else
    ShowSuccess "Deploy aura success."
  fi
  ShowAction "Aura dependencies existed. Skip aura installation."
fi

GetAccountDependency "docker" "$username"
if [ $? -ne 0 ]; then
  ShowError "Fail to add account $username to group docker depedency."
  exit 1
fi
GetAccountDependency "sudo" "$username"
if [ $? -ne 0 ]; then
  ShowError "Fail to add account $username to group docker depedency."
  exit 1
fi

#################################################################### 
# 2. Check and prepare AURA-M service scripts.
#################################################################### 
if [ ! -d "/home/$username/.auram" ]; then
  mkdir -p "/home/$username/.auram"
  sudo chown $username:$username  "/home/$username/.auram"
fi

if [ ! -d "/home/$username/.auram/stats" ]; then
  mkdir -p "/home/$username/.auram/stats"
  sudo chown $username:$username  "/home/$username/.auram/stats"
fi

GetGitDependency "start-auram.sh" "/home/$username/.auram"
if [ $? -ne 0 ]; then
  ShowError "Fail to get git file start-auram.sh depedency. Abort installation."
  exit 1
fi
GetGitDependency "stop-auram.sh" "/home/$username/.auram"
if [ $? -ne 0 ]; then
  ShowError "Fail to get git file stop-auram.sh depedency. Abort installation."
  exit 1
fi
GetGitDependency "node-json.sh" "/home/$username/.auram"
if [ $? -ne 0 ]; then
  ShowError "Fail to get git file node-json.sh depedency. Abort installation."
  exit 1
fi
GetGitDependency "add-auram-service.sh" "$DIR"
if [ $? -ne 0 ]; then
  ShowError "Fail to get git file add-auram-service.sh depedency. Abort installation."
  exit 1
fi

"$DIR/add-auram-service.sh" "$username" "/home/$username/.auram"

#################################################################### 
# 3. Check and prepare AURA-M Web Dashboard scripts.
#################################################################### 
GetAccountDependency "systemd-journal" "$username"
if [ $? -ne 0 ]; then
  ShowError "Fail to add account $username to group systemd-journal depedency."
  exit 1
fi

if [ ! -d "/home/$username/.auram/web" ]; then
  mkdir -p "/home/$username/.auram/web"
  sudo chown $username:$username  "/home/$username/.auram/web"
fi

if [ ! -d "/home/$username/.auram/web/data" ]; then
  mkdir -p "/home/$username/.auram/web/data"
  sudo chown $username:$username  "/home/$username/.auram/web/data"
fi

GetGitDependency "web/auram.html" "/home/$username/.auram" ".html" "$username:$username"
if [ $? -ne 0 ]; then
  ShowError "Fail to get git file auram.html depedency. Abort installation."
  exit 1
fi

GetGitDependency "add-web-dashboard.sh" "$DIR"
if [ $? -ne 0 ]; then
  ShowError "Fail to get git file add-web-dashboard.sh depedency. Abort installation."
  exit 1
fi

"$DIR/add-web-dashboard.sh" "$username" "/home/$username/.auram"

#################################################################### 
# 4. Check and prepare AURA-M helper scripts.
#################################################################### 
GetGitDependency "add-auram-alias.sh" "/home/$username/.auram" "" "$username:$username"
if [ $? -ne 0 ]; then
  ShowError "Fail to get git file add-auram-alias.sh depedency. Abort installation."
  exit 1
fi
helper=$(grep "add-auram-alias.sh" "/home/$username/.bashrc" -c)
if [ $helper -eq 0 ]; then
  cat >> "/home/$username/.bashrc" << EOF
source "/home/$username/.auram/add-auram-alias.sh"
EOF
  source "/home/$username/.auram/add-auram-alias.sh"
  echo "Helper script added."
else
  echo "Helper script existed."
fi
