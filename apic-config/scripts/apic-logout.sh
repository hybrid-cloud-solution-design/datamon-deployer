#!/bin/bash
source ./apic-scripts-env-setup.sh

#################
# LOGOUT OF APIC #
#################
echo " "
echo "Logout of APIC..."
apic logout --server $APIC_MGMT_SERVER