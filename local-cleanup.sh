# Stoping and Removing ALL containers
if [[ -z "$(docker ps -a -q | uniq)" ]] ; 
then
    echo "No containers to remove."
  else
    echo "Removing all containers..."
    docker rm -f $(docker ps -a -q | uniq)
fi

# Removing ALL images
if [[ -z "$(docker images -a -q | uniq)" ]] ; 
then
    echo "No images to remove."
  else
    echo "Removing all images..."
    docker rmi -f $(docker images -a -q | uniq)
fi

# Delete ALL Volumes
if [[ -z "$(docker volume ls -q | uniq)" ]] ; 
then
    echo "No volumes to remove."
  else
    echo "Removing all volumes..."
    docker rmi -f $(docker volume ls -q | uniq)
fi
