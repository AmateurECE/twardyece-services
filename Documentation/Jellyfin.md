# Configuration for Jellyfin

Jellyfin, like Jenkins, does not allow all of the configuration to be placed in
a file (e.g. that can be version-controlled). The (nontrivial) configuration
necessary to set the server up from scratch is mostly contained herein. All
other configuration, e.g. adding libraries, etc., is trivial.

# Reverse proxying under a sub-url

In order to make this work, we have to configure the sub-url in Jellyfin. Under
Admin->Dashboard, under the heading "Advanced" on the navigation pane, select
"Networking". Change "Base URL" to "/jellyfin".

# OpenLDAP

This configuration requires the `LDAP-Auth` plugin to be installed.
Configuration is very similar to the OpenLDAP config for
[Jenkins](docs/Jenkins.md).

Additionally, users must each be configured to use `LDAP-Auth` for their
authentication handler, under Admin->Dashboard->Users.
