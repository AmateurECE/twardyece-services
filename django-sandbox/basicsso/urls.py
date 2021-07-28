
from django.urls import path, include
from .views import auth

urlpatterns = [
    path('auth/', auth),
]
