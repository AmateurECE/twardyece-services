#!/bin/sh
###############################################################################
# NAME:             entrypoint.sh
#
# AUTHOR:           Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:      Entrypoint for the apps container. Sets env vars from
#                   volumes, etc.
#
# CREATED:          06/14/2021
#
# LAST EDITED:      07/05/2021
###

ENV_SUPPLEMENT=/data/environment.sh
if [ -f $ENV_SUPPLEMENT ]; then
    . $ENV_SUPPLEMENT
fi

# Set Django SECRET_KEY var
export DJANGO_SECRET_KEY=$(head -c 4096 /dev/random | sha256sum |
                               awk '{print $1}')
export DJANGO_HOSTNAME
export SCRIPT_NAME
uwsgi --ini /etc/uwsgi.ini

###############################################################################
