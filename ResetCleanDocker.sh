#!/bin/bash

# Reset & Cleanup Docker Script
# Created by Mike Lierman (@MNLierman) and @InviseLabs.
# License: OK to modify & share, please consider contributing improvements, commercial use of @MNLierman's scripts by written agreement only.
#
# This script removes Portainer and all Docker containers while keeping Docker configuration intact.
# It includes options for removing Docker images, volumes, and networks, with log_messageging capabilities.
# You would run this script on a system imaged from another that had Docker and Portainer active.

# Variables:
REMOVE_IMAGES=true  # Set to true to remove Docker images.
REMOVE_VOLUMES=true # Set to true to remove Docker volumes.
REMOVE_NETWORKS=false # Set to true to remove Docker networks.
LOGGING_ENABLED=true # Set to false to disable logging.
LOGFILE="docker_cleanup.log" # Log file location.

# Function to log_message messages
log_message() {
  if $LOGGING_ENABLED; then
    echo "$(date +'%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOGFILE"
  fi
}

log_message ""
log_message "Script started, date and time is $(date +'%Y-%m-%d %H:%M:%S')."
log_message ""

# Stopping all running containers
log_message "Stopping all running containers."
docker stop $(docker ps -aq)

# Removing all containers
log_message "Removing all containers."
docker rm $(docker ps -aq)

# Stopping and removing Portainer
log_message "Stopping and removing Portainer."
docker stop portainer
docker rm portainer
docker volume rm portainer_data

# Optional: Remove all Docker images
if [ "$REMOVE_IMAGES" = true ]; then
  log_message "Removing all Docker images."
  docker rmi $(docker images -q)
fi

# Optional: Remove all Docker volumes
if [ "$REMOVE_VOLUMES" = true ]; then
  log_message "Removing all Docker volumes."
  docker volume rm $(docker volume ls -q)
fi

# Optional: Remove all Docker networks
if [ "$REMOVE_NETWORKS" = true ]; then
  log_message "Removing all Docker networks."
  docker network rm $(docker network ls -q)
fi

# Optional: Reinstall Portainer Fresh
# docker volume create portainer_data
# docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
#docker pull portainer/portainer-ce:2.24.1
#docker run -d -p 8000:8000 -p 9443:9443 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:2.24.1

# Optional: Or run Portainer Agent on this instance
#docker run -d -p 9001:9001 --name portainer_agent --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/volumes:/var/lib/docker/volumes -v /:/host portainer/agent:2.24.1

log_message "Cleanup completed."

echo "Docker cleanup script executed successfully."

