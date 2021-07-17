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
