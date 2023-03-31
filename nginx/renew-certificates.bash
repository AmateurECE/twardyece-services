#!/bin/bash
###############################################################################
# NAME:             renew-certificates.bash
#
# AUTHOR:           Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:      Script (executed by cron) to renew SSL certificates.
#
# CREATED:          05/31/2021
#
# LAST EDITED:      03/31/2023
###

set -e

PACKAGE_NAME=twardyece
SERVICE_NAME=twardyece.com

printf '%s\n' "Checking for certificate renewal..."
webservices-certbot renew --webroot -w /var/www/certbot -n

systemctl is-active --quiet $SERVICE_NAME.service
if [[ "$?" = 0 ]]; then
    printf '%s\n' "Restarting active Nginx config (just in case)"
    podman exec -t ${PACKAGE_NAME}_nginx_1 nginx -s reload
fi

###############################################################################
