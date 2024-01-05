# Service Naming

I prefer not to name services in a way that couples them to a technology or a
provider. I've also tried naming services based on my domain name in the past.
This of course, breaks down when I decide to change my domain name.

So, I've to begin naming services based on two characteristics:

* Scope: a binding that refers to the network namespace from which a service is
  reachable. Scopes are well-defined, proper nouns in this context.
* Function: the mechanism or purpose of the service. These are obvious.

## Scopes

In the current architecture, there are two scopes:

1. Internal: refers to services that are not accessible beyond my home network
   segment.
2. Public: refers to services that are accessible from the public internet.

## Corner Cases

Some applications don't appear to fit neatly into these categories. For
example, an application hidden behind a reverse proxy is not accessed directly.
In this case, the distinction is that "a well-intentioned actor" will not be
aware that they are speaking with the service through a reverse proxy. Thus,
the application would be considered public. An OpenLDAP instance that provides
authentication to the application, on the other hand, never speaks directly
with a user. A user's actions result in requests made to the service, but no
client on the public internet may speak the LDAP protocol directly to this
service. It's for this reason that the LDAP service is considered internal.
