#!/usr/bin/bash
###############################################################################
# NAME:             start-twardyece-services.bash
#
# AUTHOR:           Ethan D. Twardy <ethan.twardy@gmail.com>
#
# DESCRIPTION:      Start my web services
#
# CREATED:          12/26/2022
#
# LAST EDITED:	    12/26/2022
#
####

ARGUMENTS=()
for definition in *.yaml; do
    ARGUMENTS+=("-f" "$file")
done

docker-compose ${ARGUMENTS[@]} up

###############################################################################
