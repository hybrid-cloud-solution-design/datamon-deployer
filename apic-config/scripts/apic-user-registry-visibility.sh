#!/bin/bash
###################
# Setup Build Env #
###################
echo "Setting up build environment..."
source ./apic-scripts-env-setup.sh
echo "${BUILD_DIR}"

if [ ! -d "$BUILD_DIR" ]
then
  echo "Creating working build directory ${PWD}/${BUILD_DIR}"
  mkdir ${BUILD_DIR}
fi

#################
# LOGIN TO APIC #
#################
./apic-login-admin.sh

##############################################################
# Ensure the API Manager User Registry has Public Visibility #
##############################################################
echo "Build visibility update file and store in ${BUILD_DIR}/api-manager-lur-public-visibility.json file..."
jq -n '.visibility.type="public"' > "${BUILD_DIR}/api-manager-lur-public-visibility.json"

echo "Update the API Manager User Registry visibility to public in APIC"
apic user-registries:update --server $APIC_MGMT_SERVER --org $APIC_ADMIN_ORG --format json 'api-manager-lur' ${BUILD_DIR}/api-manager-lur-public-visibility.json > ${BUILD_DIR}/api-manager-lur-public-visibility-output.json

#################
# Build Tidy Up #
#################
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