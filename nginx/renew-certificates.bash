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
# LAST EDITED:      06/10/2023
###

set -e

PACKAGE_NAME=twardyece
SERVICE_NAME=twardyece.com

get_timezone() {
    readlink /etc/localtime | awk -F/ '{print $(NF-1)"/"$NF}'
}

webservices-certbot() {
    local timezone=$(get_timezone)
    podman run -t --rm --name ${PACKAGE_NAME}_certbot_1 \
           -e "TZ=$timezone" \
           -v letsencrypt:/etc/letsencrypt \
           -v ${PACKAGE_NAME}_acme-challenge:/var/www/certbot \
           -v ${PACKAGE_NAME}_letsencrypt-logs:/var/log/letsencrypt \
           docker.io/certbot/certbot $@
}

printf '%s\n' "Checking for certificate renewal..."
webservices-certbot renew --webroot -w /var/www/certbot -n

systemctl is-active --quiet $SERVICE_NAME.service
if [[ "$?" = 0 ]]; then
    printf '%s\n' "Restarting active Nginx config (just in case)"
    podman exec -t ${PACKAGE_NAME}_nginx_1 nginx -s reload
fi

###############################################################################
