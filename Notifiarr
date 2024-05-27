#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
    _   __      __  _ _____                
   / | / /___  / /_(_) __(_)___ ___________
  /  |/ / __ \/ __/ / /_/ / __ `/ ___/ ___/
 / /|  / /_/ / /_/ / __/ / /_/ / /  / /    
/_/ |_/\____/\__/_/_/ /_/\__,_/_/  /_/     
                                           
                                   
                                   
EOF
}
header_info
echo -e "Loading..."
APP="Notifiarr"
var_disk="2"
var_cpu="1"
var_ram="512"
var_os="debian"
var_version="12"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  echo_default
}

function install_gnupg {
  msg_info "Installing gnupg"
  apt-get update
  apt-get install -y gnupg
  msg_ok "Installed gnupg"
}

function install_notifiarr {
  msg_info "Installing Notifiarr"
  curl -s https://golift.io/repo.sh | sudo bash -s - notifiarr
  msg_ok "Installed Notifiarr"
}

function configure_notifiarr {
  read -p "Enter your Notifiarr API Key: " api_key
  sed -i "7s/\"\"/\"${api_key}\"/" /etc/notifiarr/notifiarr.conf
  sed -i "15s/\"\"/\"admin\"/" /etc/notifiarr/notifiarr.conf
  msg_ok "Configured Notifiarr"
}

start
build_container
description

msg_info "Starting setup for $APP"
install_gnupg
install_notifiarr
configure_notifiarr

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:5454${CL} \nDefault Password is \"admin\""
