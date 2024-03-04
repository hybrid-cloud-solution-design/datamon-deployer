#!/bin/bash
source ./apic-scripts-env-setup.sh

#################
# LOGIN TO APIC #
#################
echo " "
i=0
while true
do
  # Check to see if the deployment exists and apply patch if it does
  apiccode=$(curl -kLI https://$APIC_MGMT_SERVER -o /dev/null -w '%{http_code}\n' -s)  
  echo "current apiccode: $apiccode"

  if [ -z "$apiccode" ] || [ $apiccode != "404" ] ; then
    echo "Still waiting for APIC route to respond"
  else
    echo "route exists -ending wait loop"
    break
  fi

    ((i++))
    sleep 60
    if [[ "$i" == '30' ]]; then
      echo "Route  not created within timeout limit"
      break
    fi
done    
echo "Login to APIC with CMC Admin User..."
# ./apic client-creds:clear
apic login --server $APIC_MGMT_SERVER --realm $APIC_ADMIN_REALM -u $APIC_ADMIN_USER -p $APIC_PWD