#!/bin/bash
####################  DO NOT REMOVE THESE LINES #################### 
# VERSION=0.1.0 
# FILENAME=add-web-dashboard.sh
# DESCRIPTION=AURA-M add web dashboard installation script
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

if [ $# -lt 1 ]; then
  ShowError "Insufficient parameters."
  exit 1
fi
username="$1"
DIR="$2"

mkdir "$DIR/web"

if [ -z "$DIR" ]; then
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

rand_pass=$(date +%s | sha256sum | base64 | head -c 4 ; echo)

su $username << EOF
  sudo apt install apache2-utils nginx -y
  sudo touch "$DIR/.aurampasswd"
  sudo htpasswd -b "$DIR/.aurampasswd" auram $rand_pass
EOF

ShowAction "Dashboard username: \e[1;44mauram"
ShowAction "Dashboard password: \e[1;44m$rand_pass"

dashboard=$(grep "location /aura/" "/etc/nginx/sites-available/default" -c)

if [ $dashboard -eq 0 ]; then
  content="
        location /aura/ {
                try_files \$uri \$uri/ =404;
                auth_basic \"Restricted Content\";
                auth_basic_user_file $DIR/.aurampasswd;
        }
"

  ShowAction "Creating Web Dashboard configuration."
  cat > "$DIR/tmp.replace" << EOF
$content
EOF

  sed -i "/root \/var\/www\/html;/r $DIR/tmp.replace" "/etc/nginx/sites-available/default"

  rm "$DIR/tmp.replace"
else
  ShowAction "Dashboard settings exist in nginx."
fi

su $username << EOF
sudo nginx -s reload
sudo ln -s "$DIR/web/" "/var/www/html/aura"
sudo ln -s "$DIR/web/auram.html" "/var/www/html/aura/index.html"
EOF

test=$(curl -u auram:$rand_pass --head -s http://localhost/aura/auram.html | grep 'HTTP/1.1 200 OK' -c)
if [ "$test" -eq 1 ]; then
  ShowSuccess "Nginx configured successfully."
else
  ShowError "Nginx configuration failed."
fi

exit 0