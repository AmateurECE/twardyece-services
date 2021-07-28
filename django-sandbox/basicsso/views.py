from django.shortcuts import render
from django.http import HttpResponse
import logging

GROUP_HEADER = 'SSO_GROUP_MEMBERSHIP'

# Auth view.
# This view is targeted to integrate cleanly with ngx_http_auth_request_module,
# so it does two things:
#   1: Check to make sure there is an authenticated user
#   2: Check to make sure the user is authorized, based on whether the user is
#      a member of the group in the SSO_GROUP_MEMBERSHIP header.
# If both of those checks succeed, return 200 OK. If the first check fails,
# return 401. If the second check fails, return 403.
def auth(request):
    if not request.user.is_authenticated:
        return HttpResponse(status=401)
    logging.error(request.META)
    if GROUP_HEADER not in request.META:
        return HttpResponse(status=200)
    if request.META[GROUP_HEADER] in request.user.ldap_user.group_names:
        return HttpResponse(status=200)
    logging.error(f'Header: {request.META[GROUP_HEADER]}')
    return HttpResponse(status=403)
