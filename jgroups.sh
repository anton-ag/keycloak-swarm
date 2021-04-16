#!/bin/bash

# If JGROUPS_DISCOVERY_PROPERTIES is set, it must be in the following format: PROP1=FOO,PROP2=BAR
# If JGROUPS_DISCOVERY_PROPERTIES_DIRECT is set, it must be in the following format: {PROP1=>FOO,PROP2=>BAR}
# It's a configuration error to set both of these variables

if [ -n "$JGROUPS_DISCOVERY_PROTOCOL" ]; then
    if [ -n "$JGROUPS_DISCOVERY_PROPERTIES" ] && [ -n "$JGROUPS_DISCOVERY_PROPERTIES_DIRECT" ]; then
       echo >&2 "error: both JGROUPS_DISCOVERY_PROPERTIES and JGROUPS_DISCOVERY_PROPERTIES_DIRECT are set (but are exclusive)"
       exit 1
    fi

    if [ -n "$JGROUPS_DISCOVERY_PROPERTIES_DIRECT" ]; then
      JGROUPS_DISCOVERY_PROPERTIES_PARSED="$JGROUPS_DISCOVERY_PROPERTIES_DIRECT"
    else
# ======================================================================================================
      # dynamic discovery wrapper. For correct work, JGROUPS_DISCOVERY_PROPERTIES_DIRECT must not be set
      # stack is the name of stack, stack_keycloak is the name of service
      peerIps=`host tasks.stack_keycloak | awk '{print $4}'`
      args="initial_hosts=>\""
      for ip in $peerIps; do
      args="$args$ip[7600],"
      done
      args=${args%?}
      JGROUPS_DISCOVERY_PROPERTIES_PARSED="{$args\"}"
    fi
# ======================================================================================================

    echo "Setting JGroups discovery to $JGROUPS_DISCOVERY_PROTOCOL with properties $JGROUPS_DISCOVERY_PROPERTIES_PARSED"
    echo "set keycloak_jgroups_discovery_protocol=${JGROUPS_DISCOVERY_PROTOCOL}" >> "$JBOSS_HOME/bin/.jbossclirc"
    echo "set keycloak_jgroups_discovery_protocol_properties=${JGROUPS_DISCOVERY_PROPERTIES_PARSED}" >> "$JBOSS_HOME/bin/.jbossclirc"
    echo "set keycloak_jgroups_transport_stack=${JGROUPS_TRANSPORT_STACK:-tcp}" >> "$JBOSS_HOME/bin/.jbossclirc"
    # If there's a specific CLI file for given protocol - execute it. If not, we should be good with the default one.
    if [ -f "/opt/jboss/tools/cli/jgroups/discovery/$JGROUPS_DISCOVERY_PROTOCOL.cli" ]; then
       $JBOSS_HOME/bin/jboss-cli.sh --file="/opt/jboss/tools/cli/jgroups/discovery/$JGROUPS_DISCOVERY_PROTOCOL.cli" >& /dev/null
    else
       $JBOSS_HOME/bin/jboss-cli.sh --file="/opt/jboss/tools/cli/jgroups/discovery/default.cli" >& /dev/null
    fi
fi
