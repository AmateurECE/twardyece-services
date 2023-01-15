#!/usr/bin/bash
###############################################################################
# NAME:             twardyece-services.bash
#
# AUTHOR:           Ethan D. Twardy <ethan.twardy@gmail.com>
#
# DESCRIPTION:      Run docker-compose for my web services
#
# CREATED:          12/26/2022
#
# LAST EDITED:	    01/15/2023
#
####

ARGUMENTS=()
for definition in *.yaml; do
    ARGUMENTS+=("-f" "$definition")
done

docker-compose ${ARGUMENTS[@]} "$@"

###############################################################################
