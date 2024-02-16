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