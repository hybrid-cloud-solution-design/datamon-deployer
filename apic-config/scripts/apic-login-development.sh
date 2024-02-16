#!/bin/bash
source ./apic-scripts-env-setup.sh

#################
# LOGIN TO APIC #
#################
echo " "
echo "Login to APIC as Development pOrg Owner - $PORG_DEV_OWNER_USER"
apic login --server $APIC_MGMT_SERVER --realm $APIC_PROVIDER_REALM -u $PORG_DEV_OWNER_USER -p $PORG_DEV_OWNER_PWD