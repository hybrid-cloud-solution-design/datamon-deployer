#!/bin/bash
###################
# Setup Build Env #
###################
echo " "
echo "Setting up build environment..."
source ./apic-scripts-env-setup.sh
echo "${BUILD_DIR}"

if [ ! -d "$BUILD_DIR" ]
then
  echo "  Creating working build directory ${PWD}/${BUILD_DIR}"
  mkdir ${BUILD_DIR}
fi

#############################
# LOGIN TO Development pOrg #
#############################
./apic-login-development.sh

#############################
# Create & Config Catalog   #
#############################
echo " "
echo "Create $CAT_DEV_NAME Catalog in Dev pOrg..."
echo "  Build create Catalog file - ${BUILD_DIR}/${CAT_DEV_NAME}-dev-create.json"
jq -n \
  --arg CAT_DEV_TITLE "$CAT_DEV_TITLE" \
  --arg CAT_DEV_NAME "$CAT_DEV_NAME" \
  '.title=$CAT_DEV_TITLE | .name=$CAT_DEV_NAME' \
  > ${BUILD_DIR}/${CAT_DEV_NAME}-dev-create.json


echo "  Create Catalog by applying the ${BUILD_DIR}/${CAT_DEV_NAME}-dev-create.json file storing result in ${BUILD_DIR}/${CAT_DEV_NAME}-dev-create-output.json"
apic catalogs:create --server $APIC_MGMT_SERVER --org $PORG_DEV_NAME --format json ${BUILD_DIR}/${CAT_DEV_NAME}-dev-create.json > ${BUILD_DIR}/${CAT_DEV_NAME}-dev-create-output.json

echo "  Looking up the URL for the portal-service"
CAT_DEV_PORTAL_SERVICE_URL=$(apic portal-services:list --server $APIC_MGMT_SERVER --scope org --org $PORG_DEV_NAME --format json | jq -r '.results[].url')
echo "  portal-service url - $CAT_DEV_PORTAL_SERVICE_URL"

i=0
while true
do
  CAT_DEV_PORTAL_SERVICE_URL=$(apic portal-services:list --server $APIC_MGMT_SERVER --scope org --org $PORG_DEV_NAME --format json | jq -r '.results[].url')
  echo "  portal-service url - $CAT_DEV_PORTAL_SERVICE_URL"
  # Check to see if portal-service ready
  # oc get -n integration deployment -l app.kubernetes.io/name=juhu
  if [ -z "$CAT_DEV_PORTAL_SERVICE_URL" ] ; then
    echo "Still waiting for portal-service to exist"
  else
    echo "portal-service exists -ending wait loop"
    break
  fi

  # Check to make sure the job hasn't completed
  # is_complete=$(oc get -n $(params.namespace) job/cloud-pak-deployer -o yaml | yq '.status.conditions.[] | select(.type == "Complete") | contains({"status": "'True'"})')
  # did_fail=$(oc get -n $(params.namespace) job/cloud-pak-deployer -o yaml | yq '.status.conditions.[] | select(.type == "Failed") | contains({"status": "'True'"})')
  #if [ $is_complete != "true" ] | [ $did_fail == "true" ] ; then
  #  echo "$is_complete"
  #  echo "$did_fail"
  #  echo "Cloud Pak Deployer job is Complete"
  #  break
  #fi

  ((i++))
  sleep 60
  if [[ "$i" == '700' ]]; then
    echo "portal-service not created within timeout limit"
    break
  fi
done

### gas commented - approvals not needed
#   '.portal.portal_service_url=$CAT_DEV_PORTAL_SERVICE_URL | .portal.type="drupal" | .product_lifecycle_approvals=["staged","published","deprecated","retired","replace","supersede"]' \


echo "  Build the catalog setting update for the ${CAT_DEV_TITLE} catalog in the Dev pOrg to add the Portal and Approval Settings"
echo "  Catalog setting update file stored in ${BUILD_DIR}/${CAT_DEV_NAME}-dev-catalog-settings-update.json"
jq -n \
 --arg CAT_DEV_PORTAL_SERVICE_URL "$CAT_DEV_PORTAL_SERVICE_URL" \
  '.portal.portal_service_url=$CAT_DEV_PORTAL_SERVICE_URL | .portal.type="drupal" ' \
  > ${BUILD_DIR}/${CAT_DEV_NAME}-dev-catalog-settings-update.json

echo "  Update the catalog setting for the ${CAT_DEV_TITLE} catalog in the Dev pOrg to add the Portal and Approval Settings"
echo "  Result of update stored in file ${BUILD_DIR}/${CAT_DEV_NAME}-dev-catalog-settings-update-output.json"
apic catalog-settings:update --server $APIC_MGMT_SERVER --org $PORG_DEV_NAME --format json --catalog ${CAT_DEV_NAME} ${BUILD_DIR}/${CAT_DEV_NAME}-dev-catalog-settings-update.json > ${BUILD_DIR}/${CAT_DEV_NAME}-dev-catalog-settings-update-output.json


#################
# Build Tidy Up #
#################
echo " "
if [ ${BUILD_TIDY_UP} = true ]
then
  echo "Deleting build files..."
else
  echo "Leaving build files for debuging..."
fi

####################
# LOGOUT FROM APIC #
####################
./apic-logout.sh