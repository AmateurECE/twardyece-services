# Migrating to a New Machine

# Migrating to a New Hostname

#. The [MkDocs Repository](https://github.com/AmateurECE/MkDocsRepository)
   makes use of a GitHub webhook to trigger the Jenkins CI build.
#. The OpenLDAP database root DN should contain the server domain name. The
   value of the root DN is hardcoded into the Jenkins Global Security
   configuration, as well as the Django `apps` LDAP settings. It's reasonable
   to assume that any client of the OpenLDAP server will have the root DN
   hardcoded, so this will naturally need to be changed in multiple places.
#. A thorough `grep` of the repository should identify other places where the
   hostname needs to be changed.
