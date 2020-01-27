function rm_containers
    docker ps -a | cut -f 1 -d ' ' | tail -n +2 | xargs docker rm
end
