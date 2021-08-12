# Jenkins Configuration

As cool as Jenkins is, it's written in Java, and the Java folks haven't quite
embraced the "configuration as code" mantras common in today's infrastructure.
I've documented the important parts of the Jenkins configuration here, in case
I ever need to re-create it from scratch.

From a high level, the Jenkins builds are executed on an agent, connected
remotely to the controller. Both the agent and the controller are separate
containers on the host. The agent must be _configured_ on the controller first,
before the agent can connect successfully to the controller.

# Jenkins Controller

Create a new permanent agent in the usual way. Important configuration is
listed below:

#. *Remote root directory*: _/home/jenkins/agent_. The workspace directory of
   the agent. This value is passed to the agent upon its invocation.
#. *Launch method*: _Launch agent by connecting it to the master_. It's totally
   not obvious, but expanding the help shows that this configuration allows
   agents to connect with the JNLP4-Connect protocol.
#. *Advanced*->*Tunnel connection through*:
   _edtwardy-webservices\_jenkins-controller_1:50000_. This is necessary to
   instruct the agent, once configured, to connect to this address for
   communication. It appears that this parameter appears somewhere in the
   generated `.jnlp` file.

# Jenkins Agent

Though we are using the JNLP4-Connect protocol, which appears to be the exact
use case for the Docker Inbound Agent, we chose to use the
[Docker Agent](https://hub.docker.com/r/jenkins/agent) as the base image. To
start an agent using the base image, the following Docker CLI invocation can be
used:

```
docker run \
    --network edtwardy-webservices_default \
    --init jenkins/agent \
    java -jar /usr/share/jenkins/agent.jar \
    -jnlpUrl http://edtwardy-webservices_jenkins-controller_1:8080/jenkins/computer/docker-agent/jenkins-agent.jnlp \
    -secret <secret> \
    -workDir "/home/jenkins/agent"
```

The `<secret>` must come from the Jenkins controller; it's a part of the
configuration automatically generated when the permanent agent is created.
Additionally, the `workDir` field can be anything, but the agent and the
controller must agree on its location.

For images derived of the `jenkins/agent` image, such as the one in use at the
time of this writing, I had to reset the container user to `root`, and then
create a shell script entrypoint to change ownership of some mounted volumes,
and then execute the agent `.jar` as the `jenkins` user. While this is not
ideal, I don't currently have a better workaround for it.

# LDAP

This is, for the most part, intuitive. Obviously, securing using LDAP requires
the OpenLDAP server to be running, and the LDAP plugin to be installed. LDAP
configuration can be found under *Configure Jenkins*->*Configure Global
Security*. The following settings are currently used (as of Jenkins 2.306), but
may change as Jenkins and/or the LDAP plugin are updated:

#. *Server*: _edtwardy-webservices\_openldap\_1_
#. *root DN*: _dc=edtwardy,dc=hopto,dc=org_
#. *User search base*: _ou=people_
#. *User search filter*: _uid={0}_
#. *Group search base*: _ou=groups_
#. *Group membership*: _Search for LDAP groups containing user_. The *Group
   membership filter* field remains empty.
#. *Display Name LDAP attribute*: _uid_
#. *Email Address LDAP attribute*: _mail_. At the time of this writing, LDAP
   users don't have a _mail_ attribute, but if this field is left empty, the
   LDAP plugin will fail.

# Projects

For projects that require GitHub webhook integration, it's necessary to enable
_GitHub hook trigger for GITScm polling_ under *Build Triggers*. This is
contrary to some pages online that suggest selecting _Poll SCM_ with no
interval specified, which is *not* a working configuration as of Jenkins 2.306.
