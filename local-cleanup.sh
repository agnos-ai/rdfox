#!/usr/bin/env bash

source ./terminal.sh
customize_terminal_output

# Stop and RemoveALL containers

echo "${header}Stop and remove containers${reset}"

if [[ -z "$(docker ps -a -q | uniq)" ]] ; 
then
    echo "${info}No containers to remove${reset}"
  else
    docker rm -f $(docker ps -a -q | uniq) || exit 1
    echo "${info}All containers have been removed${reset}"
fi

# Remove ALL images

echo "${header}Remove images${reset}"

if [[ -z "$(docker images -a -q | uniq)" ]] ; 
then
    echo "${info}No images to remove${reset}"
  else
    docker rmi -f $(docker images -a -q | uniq) || exit 1
    echo "${info}All images have been removed${reset}"
fi

# Delete ALL Volumes
echo "${header}Delete volumes${reset}"

if [[ -z "$(docker volume ls -q | uniq)" ]] ; 
then
    echo "${info}No volumes to delete${reset}"
  else
    docker rmi -f $(docker volume ls -q | uniq)  || exit 1
    echo "${info}All volumes have been deleted${reset}" 
fi
