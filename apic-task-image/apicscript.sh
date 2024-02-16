#!/bin/bash
# source ./apic-scripts-env-setup.sh
#
set -x
# gas - changing to env
echo "Listing env vars:"
env
#echo "APIC_NAMESPACE=$APIC_NAMESPACE"

#APIC_MGMT_SERVER=$(oc get route -l app.kubernetes.io/name=platform-api-endpoint -n $APIC_NAMESPACE -o jsonpath="{.items[].spec.host}")
#PORG_DEV_NAME="esg-development"
#CAT_DEV_NAME="esg-portfolio-anaylsis"

APIC_PROVIDER_REALM="provider/default-idp-2"
##PORG_DEV_OWNER_FN="dev"
##PORG_DEV_OWNER_LN="org-owner"
##CUSTOMER_NAME="lseg"
#PORG_DEV_OWNER_USER="${PORG_DEV_OWNER_FN}.${PORG_DEV_OWNER_LN}@${CUSTOMER_NAME}.com"
#PORG_DEV_OWNER_PWD="passw0rd"

echo " "
echo "Need to accept license..."
apic --debug --accept-license --live-help=false
#################
# LOGIN TO APIC #
#################
echo " "
echo "Login to APIC as Development pOrg Owner - $PORG_DEV_OWNER_USER"
apic login --server $APIC_MGMT_SERVER --realm $APIC_PROVIDER_REALM -u $PORG_DEV_OWNER_USER -p $PORG_DEV_OWNER_PWD

echo " "
echo "Downloading OpenAPI definition from Code Engine server"

API_DEF="./openapi.json"
# export SERVICE_URL="http://test-app-datamon-test.apps.65af81ab8957d90010952146.cloud.techzone.ibm.com"
response=$(curl -o openapi.json -X POST $APIGEN_URL -H 'Content-Type: application/json' -d  "{\"service-url\": \"$SERVICE_URL\"}")
echo " "
echo "Schema is as follows:"
cat $API_DEF
echo " "
API_TITLE=$(jq -r .info.title openapi.json)
echo "API title is $API_TITLE"

# Validate JSON file
echo " "
echo "Validating API file..."
apic validate $API_DEF

echo " "
echo "Listing development catalogues"
apic catalogs:list -s $APIC_MGMT_SERVER -o $PORG_DEV_NAME

## GAS 
# Create draft API
echo "Creating draft API..."
apiresp=$(apic draft-apis:create --server $APIC_MGMT_SERVER --org $PORG_DEV_NAME openapi.json)

# check for error
if [[ "${apiresp}" == *"Error"* ]] ;then
    echo $apiresp
    exit 0
fi

# extract api version - var%%X* gets al till first X character
fullName=${apiresp%% *}
versionNumber=${fullName#*:}
echo "API name $fullName extracted verson:$versionNumber"


# Create corresponding product - creates - new-esg-apis.yaml
echo " "
echo "Creating product from APIs..."
apic create:product --title "$API_TITLE" --version $versionNumber --apis $API_DEF --gateway-type datapower-api-gateway --filename apis.yaml

## GAS
# Create draft
echo "Creating draft product from APIs..."
apic draft-products:create --server $APIC_MGMT_SERVER --org $PORG_DEV_NAME apis.yaml

# Validate corresponding product
echo " "
echo "Validating product from APIs..."
apic validate ./apis.yaml --product-only

echo " "
cat ./apis.yaml

# Publish corresponding product
echo " "
echo "Publishing product and apis..."
apic products:publish ./apis.yaml --stage -c $CAT_DEV_NAME  -o $PORG_DEV_NAME -s $APIC_MGMT_SERVER

# List what's in cataloge
echo " "
echo "Catalogue now looks like..."
apic products:list-all --scope catalog -c $CAT_DEV_NAME -s $APIC_MGMT_SERVER -o $PORG_DEV_NAME

echo " "
echo "apicscript complete"