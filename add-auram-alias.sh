#!/bin/bash
####################  DO NOT REMOVE THESE LINES #################### 
# VERSION=0.1.0 
# FILENAME=install-auram-alias.sh
# DESCRIPTION=AURA-M add command aliases installation script
####################################################################
function auram() {
  if [ "$1" == "start" ]; then
    sudo systemctl start aura-m
  elif [ "$1" == "stop" ]; then
    sudo systemctl stop aura-m
  elif [ "$1" == "status" ]; then
    sudo systemctl status aura-m
  elif [ "$1" == "logs" ]; then
    sudo journalctl -u aura-m -f
  fi
}