#!/bin/bash
# Created: 05/03/2023

container=$1
operation=$2
namespace=$(awk -F_ '{print $1}' <<< $container)
service=$(awk -F_ '{print $2}' <<< $container)

file="${namespace}/${service}.yaml"
if [[ ! -f $file ]]; then
    >&2 printf 'Error: %s\n' "Service file $file does not exist"
    exit 1
fi

docker-compose -f $file $operation
