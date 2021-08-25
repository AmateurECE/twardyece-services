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
# LAST EDITED:      08/24/2021
###

set -e

PACKAGE_NAME=edtwardy-webservices

printf '%s\n' "Checking for certificate renewal..."
CERT_PATH=/etc/letsencrypt/live/edtwardy.hopto.org/cert.pem
# Check certificate renewal status, renew if necessary
docker run -t --rm --name ${PACKAGE_NAME}_certbot_1 \
       -v letsencrypt:/etc/letsencrypt \
       -v ${PACKAGE_NAME}_acme-challenge:/var/www/certbot \
       -v ${PACKAGE_NAME}_letsencrypt-logs:/var/log/letsencrypt \
       certbot/certbot certonly \
       -d edtwardy.hopto.org \
       --webroot \
       -w /var/www/certbot \
       -n

systemctl is-active --quiet $PACKAGE_NAME.service
if [[ "$?" = 0 ]]; then
    printf '%s\n' "Restarting active Nginx config (just in case)"
    docker exec -t ${PACKAGE_NAME}_nginx_1 nginx -s reload
fi

###############################################################################
