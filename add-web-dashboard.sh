#!/bin/bash
####################  DO NOT REMOVE THESE LINES #################### 
# VERSION=0.1.0 
# FILENAME=add-web-dashboard.sh
# DESCRIPTION=AURA-M add web dashboard installation script
####################################################################
if [ $# -lt 1 ]; then
  echo "Insufficient parameters."
  exit 1
fi
username="$1"
DIR="$2"

if [ -z "$DIR" ]; then
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

rand_pass=$(date +%s | sha256sum | base64 | head -c 4 ; echo)

su $username << EOF
  sudo apt install apache2-utils nginx -y
  sudo touch "$DIR/.aurampasswd"
  sudo htpasswd -c "$DIR/.aurampasswd" auram $rand_pass
EOF

echo "Dashboard password: $rand_pass"

dashboard=$(grep "location /aura/" "/etc/nginx/sites-available/default" -c)

if [ $dashboard -ne 0 ]; then
  echo "Dashboard settings exist in nginx."
  exit 0
fi

content="
        location /aura/ {
                try_files $uri $uri/ =404;
                auth_basic ""Restricted Content"";
                auth_basic_user_file ""$DIR/.aurampasswd"";
        }
"

echo "Creating Web Dashboard configuration."
cat > "$DIR/tmp.replace" << EOF
$content
EOF

sed -i "/root \/var\/www\/html;/a $DIR/tmp.replace" "/etc/nginx/sites-available/default"

rm "$DIR/tmp.replace"

exit 0