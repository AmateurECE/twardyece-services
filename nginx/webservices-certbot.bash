#!/bin/bash
###############################################################################
# NAME:             webservices-certbot.bash
#
# AUTHOR:           Ethan D. Twardy <ethan.twardy@gmail.com>
#
# DESCRIPTION:      Script (executed by cron) to renew SSL certificates.
#
# CREATED:          05/31/2021
#
# LAST EDITED:      01/11/2024
###

set -e

get_timezone() {
    readlink /etc/localtime | awk -F/ '{print $(NF-1)"/"$NF}'
}

webservices-certbot() {
    local timezone=$(get_timezone)
    podman run -t --rm --name internal_certbot \
           -e "TZ=$timezone" \
           -v systemd-ssl-letsencrypt:/etc/letsencrypt \
           -v systemd-acme-challenge:/var/www/certbot \
           -v twardyece-letsencrypt-logs:/var/log/letsencrypt \
           docker.io/certbot/certbot $@
}

renew() {
    printf '%s\n' "Checking for certificate renewal..."
    webservices-certbot renew --webroot -w /var/www/certbot -n

    systemctl is-active --quiet nginx.service
    if [[ "$?" = 0 ]]; then
        printf '%s\n' "Restarting active Nginx config (just in case)"
        podman exec -t public_reverse-proxy nginx -s reload
    fi
}

subcommand="$1"; shift
case "$subcommand" in
    renew)
        renew
	;;
    cmd)
        webservices-certbot $@
	;;
    *)
        >&2 printf '%s\n' "$0 <subcommand>" "Subcommands:" "\trenew" \
            "\tcmd [ARGS ..]"
        ;;
esac

###############################################################################
