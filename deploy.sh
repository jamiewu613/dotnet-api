compose_file=docker-compose.prod.yml
# service_name=backend

mode=${1:-all}
if [ $mode == 'backend' ] || [ $mode == 'admin' ]
then
  echo 'Deploy' $mode
else
  echo 'Deploy All' 
  mode='backend admin'
fi


reload_nginx() {  
  # docker exec nginx /usr/sbin/nginx -s reload  
  docker-compose -f $compose_file exec nginx /usr/sbin/nginx -s reload
}

# Check if nginx is started
if [ -z `docker-compose -f $compose_file ps -q nginx` ]
then
  docker-compose -f $compose_file up \
    -d \
    nginx
else
  echo "nginx is started."
fi

deploy() {
  service_name=$1
  sha=$(git rev-parse --short HEAD)
  old_container_ids=$(docker-compose -f $compose_file ps -q $service_name)
  replicas=`echo $old_container_ids | wc -l`

  # bring a new container online, running new code  
  # (nginx continues routing to the old container only)  
  TAG=$sha \
  docker-compose -f $compose_file up \
    -d \
    --no-deps \
    --scale $service_name=$(expr 2 \* $replicas) \
    --no-recreate \
    --build \
    $service_name


  # start routing requests to the new container (as well as the old)
  reload_nginx

  # # Not working for `replicated` mode, cause of there are no ports exposed
  # # wait for new container to be available  
  # new_container_id=$(docker ps -f name=$service_name -q | head -n1)
  # new_container_ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $new_container_id)
  # curl --silent --include --retry-connrefused --retry 30 --retry-delay 1 --fail http://$new_container_ip:3000/ || exit 1


  # take the old container offline  
  if [ -n $old_container_ids ]
  then
    docker stop $old_container_ids
    docker rm $old_container_ids
  fi

  docker-compose -f $compose_file up \
    -d \
    --no-deps \
    --scale $service_name=$(expr 1 \* $replicas) \
    --no-recreate \
    $service_name

  reload_nginx
}

for item in $mode; do
  deploy $item
done
