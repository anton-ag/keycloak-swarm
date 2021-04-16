FROM jboss/keycloak:12.0.4

# add TCPPING discovery protocol settings
COPY --chown=jboss cli/TCPPING.cli /opt/jboss/tools/cli/jgroups/discovery/

# add bind-utils utilities
USER root
RUN microdnf update -y && microdnf install -y bind-utils && microdnf clean all

# add custom script for dynamic discovery
USER 1000
COPY --chown=jboss jgroups.sh /opt/jboss/tools/
RUN chmod 775 /opt/jboss/tools/jgroups.sh

# launch options
CMD [ "-b", "0.0.0.0" ]