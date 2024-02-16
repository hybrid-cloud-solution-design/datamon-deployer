#!/bin/bash
source ./apic-scripts-env-setup.sh

#################
# LOGIN TO APIC #
#################
echo " "
echo "Login to APIC with CMC Admin User..."
# ./apic client-creds:clear
apic login --server $APIC_MGMT_SERVER --realm $APIC_ADMIN_REALM -u $APIC_ADMIN_USER -p $APIC_PWD