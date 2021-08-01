# Using the Django Sandbox

This sandbox can be used to test Django applications, or to generate test
applications locally. The repository is configured to ignore project files in
the django-sandbox directory, so one can easily set up a sandbox project here
directly after cloning.

## The `authtest` app

This app contains just one view, registered to `/`, which requires the user to
be logged in. It can be used, e.g., to test the project auth/auth
configuration. To use, simply build the wheel, add to the container, then plug
in to the Django project configuration:

```
project/django-sandbox$ python3 setup.py bdist_wheel

Containerfile:
FROM ... as builder
COPY django-sandbox/dist/*.whl /root/dist/

apps/apps/settings.py:
INSTALLED_APPLICATIONS = [
    ...
    authtest,
    ...
]

apps/apps/urls.py:
urlpatterns = [
    ...
    path('authtest/', include('authtest.urls')),
    ...
]
```

## Authenticating from the Shell

```
from django_auth_ldap.backend import LDAPBackend, populate_user
user = LDAPBackend().populate_user('username')
user.ldap_user.group_names...
```

## The `basicsso` app

This is a stupid simple application to return auth error codes when the browser
requesting the resource is not authorized to view the resource. To integrate
the app with an existing Nginx config and protect a static resource, first add
the authorization endpoint:

```
location = /apps/basicsso/auth/ {
    internal;
    uwsgi_pass edtwardy-webservices_apps_1:8000;
    include /etc/nginx/conf.d/uwsgi_params;
    uwsgi_pass_request_body off;
    uwsgi_param SSO_GROUP_MEMBERSHIP $sso_group_param;
    uwsgi_param X-Original-URI $request_uri;
}
```

Then, connect it to a resource needing authorization. In this case, the user
must be part of the `Bookmarks` group to access the resource.

```
location /grouptest/ {
    set $sso_group_param "Bookmarks";
    auth_request /apps/basicsso/auth/;
    root /var/www/grouptest;
}
```
