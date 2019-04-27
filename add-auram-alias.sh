#!/bin/bash
####################  DO NOT REMOVE THESE LINES #################### 
# VERSION=0.1.0 
# FILENAME=install-auram-alias.sh
# DESCRIPTION=AURA-M add command aliases installation script
####################################################################
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function auram() {
  if [ "$1" == "start" ]; then
    sudo systemctl start aura-m
  elif [ "$1" == "stop" ]; then
    sudo systemctl stop aura-m
  elif [ "$1" == "status" ]; then
    sudo systemctl status aura-m
  elif [ "$1" == "logs" ]; then
     journalctl -u aura-m -f
  elif [ "$1" == "pass" ]; then
    if [ ! -z "$2" ] && [ ! -z "$3" ]; then
      sudo htpasswd -b "$DIR/.aurampasswd" "$2" "$3"
    else
      echo "Required in following format. auram pass <username> <password>"
    fi
  else
    echo "Unknown auram command."
  fi
}
