#!/bin/bash

# Function to create an LXC container
create_lxc() {
  local CTID=$1
  local HOSTNAME=$2
  local CPUS=$3
  local RAM=$4
  local STORAGE=$5
  local TEMPLATE=$6
  local BRIDGE=$7
  local PORT=$8

  # Create the container
  pct create $CTID $TEMPLATE -hostname $HOSTNAME -cores $CPUS -memory $RAM -rootfs ${STORAGE} -net0 name=eth0,bridge=$BRIDGE,ip=dhcp -password $PVE_PASS -features nesting=1

  if [ $? -ne 0 ]; then
    echo "Failed to create container $CTID ($HOSTNAME)"
    return 1
  fi

  # Start the container
  pct start $CTID

  if [ $? -ne 0 ]; then
    echo "Failed to start container $CTID ($HOSTNAME)"
    return 1
  fi

  # Retrieve the IP address
  sleep 5  # Wait for the container to fully start
  IP_ADDRESS=$(pct exec $CTID -- ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}.\d+')

  echo "$HOSTNAME is accessible at http://$IP_ADDRESS:$PORT"
  return 0
}

# Template and bridge details
TEMPLATE="local:vztmpl/debian-11-standard_11.0-1_amd64.tar.gz"
BRIDGE="vmbr0"

# Recommended resources
resources=(
  "Notifarr|201|notifarr|1|512|8G|8080"
  "Jellyfin|202|jellyfin|2|2048|32G|8096"
  "Plex|203|plex|2|2048|32G|32400"
  "Prowlarr|204|prowlarr|1|512|8G|9696"
  "SabNZBD|205|sabnzbd|1|1024|16G|8080"
  "Sonarr|206|sonarr|1|1024|16G|8989"
  "Radarr|207|radarr|1|1024|16G|7878"
  "Lidarr|208|lidarr|1|1024|16G|8686"
  "Readarr|209|readarr|1|1024|16G|8787"
  "NGINX|210|nginx|1|512|8G|80"
  "Bazarr|211|bazarr|1|512|8G|6767"
  "Overseerr|212|overseerr|1|1024|16G|5055"
  "Jellyseerr|213|jellyseerr|1|1024|16G|5055"
  "UptimeKuma|214|uptimekuma|1|512|8G|3001"
)

# Ask user for choices
read -p "Choose media server (1 for Jellyfin, 2 for Plex): " media_choice
if [[ $media_choice == "1" ]]; then
  media_server="Jellyfin"
else
  media_server="Plex"
fi

read -p "Choose request management (1 for Overseerr, 2 for Jellyseerr): " request_choice
if [[ $request_choice == "1" ]]; then
  request_manager="Overseerr"
else
  request_manager="Jellyseerr"
fi

# Prompt for password
read -s -p "Enter new password: " PVE_PASS
echo
read -s -p "Retype new password: " PVE_PASS_CONFIRM
echo

if [[ $PVE_PASS != $PVE_PASS_CONFIRM ]]; then
  echo "Passwords do not match."
  exit 1
fi

# Create containers
for res in "${resources[@]}"; do
  IFS='|' read -r -a params <<< "$res"
  CTID=${params[1]}
  HOSTNAME=${params[2]}
  CPUS=${params[3]}
  RAM=${params[4]}
  STORAGE="local-lvm:${params[5]}"  # Change this line to use the correct storage backend
  PORT=${params[6]}

  # Skip the non-selected media server and request manager
  if [[ $HOSTNAME == "jellyfin" && $media_server == "Plex" ]]; then
    continue
  elif [[ $HOSTNAME == "plex" && $media_server == "Jellyfin" ]]; then
    continue
  elif [[ $HOSTNAME == "overseerr" && $request_manager == "Jellyseerr" ]]; then
    continue
  elif [[ $HOSTNAME == "jellyseerr" && $request_manager == "Overseerr" ]]; then
    continue
  fi

  create_lxc $CTID $HOSTNAME $CPUS $RAM $STORAGE $TEMPLATE $BRIDGE $PORT
done

echo "All selected LXC containers have been created and started."
