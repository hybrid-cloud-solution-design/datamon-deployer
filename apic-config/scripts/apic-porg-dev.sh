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

#################
# LOGIN TO APIC #
#################
./apic-login-admin.sh

###########################
# Create Development pOrg #
###########################
echo " "
echo "Build Dev pOrg owner update file and store in ${BUILD_DIR}/${PORG_DEV_OWNER_USER}.json file..."
jq -n \
  --arg PORG_DEV_OWNER_FN "$PORG_DEV_OWNER_FN" \
  --arg PORG_DEV_OWNER_LN "$PORG_DEV_OWNER_LN" \
  --arg PORG_DEV_OWNER_EMAIL "$PORG_DEV_OWNER_EMAIL" \
  --arg PORG_DEV_OWNER_USER "$PORG_DEV_OWNER_USER" \
  --arg PORG_DEV_OWNER_PWD "$PORG_DEV_OWNER_PWD" \
  '.username=$PORG_DEV_OWNER_USER | .email=$PORG_DEV_OWNER_EMAIL | .first_name=$PORG_DEV_OWNER_FN | .last_name=$PORG_DEV_OWNER_LN | .password=$PORG_DEV_OWNER_PWD' \
  > "${BUILD_DIR}/${PORG_DEV_OWNER_USER}.json"

echo "  Creating the pOrg owner ($PORG_DEV_OWNER_USER) in APIC using generated ${BUILD_DIR}/${PORG_DEV_OWNER_USER}.json file..."
apic users:create --server $APIC_MGMT_SERVER --org $APIC_ADMIN_ORG --user-registry 'api-manager-lur' --format json ${BUILD_DIR}/${PORG_DEV_OWNER_USER}.json > ${BUILD_DIR}/${PORG_DEV_OWNER_USER}-create-output.json

echo "  Get the URL for the user"
PORG_DEV_OWNER_USER_URL=$(cat ${BUILD_DIR}/${PORG_DEV_OWNER_USER}-create-output.json | jq -r '.url')
echo "  New User URL - $PORG_DEV_OWNER_USER_URL"

echo " "
echo "Build Dev pOrg file and store in ${BUILD_DIR}/${PORG_DEV_NAME}.json file..."
jq -n \
  --arg PORG_DEV_TITLE "$PORG_DEV_TITLE" \
  --arg PORG_DEV_NAME "$PORG_DEV_NAME" \
  --arg PORG_DEV_OWNER_USER_URL "$PORG_DEV_OWNER_USER_URL" \
  '.title=$PORG_DEV_TITLE | .name=$PORG_DEV_NAME | .owner_url=$PORG_DEV_OWNER_USER_URL' \
  > "${BUILD_DIR}/${PORG_DEV_NAME}.json"

echo " "
echo "Creating the pOrg ($PORG_DEV_TITLE) in APIC using generated ${BUILD_DIR}/${PORG_DEV_NAME}.json file..."
apic orgs:create --server $APIC_MGMT_SERVER --format json ${BUILD_DIR}/${PORG_DEV_NAME}.json > ${BUILD_DIR}/${PORG_DEV_NAME}-create-output.json

### gas commented this section - not needed for demo, left for future expansion

#################################
# Create Development pOrg Users #
#################################
# echo " "
# echo "Build API Admin user create file and store in ${BUILD_DIR}/${PORG_DEV_APIADMIN_USER}.json file..."
# jq -n \
#   --arg PORG_DEV_APIADMIN_FN "$PORG_DEV_APIADMIN_FN" \
#   --arg PORG_DEV_APIADMIN_LN "$PORG_DEV_APIADMIN_LN" \
#   --arg PORG_DEV_APIADMIN_EMAIL "$PORG_DEV_APIADMIN_EMAIL" \
#   --arg PORG_DEV_APIADMIN_USER "$PORG_DEV_APIADMIN_USER" \
#   --arg PORG_DEV_APIADMIN_PWD "$PORG_DEV_APIADMIN_PWD" \
#   '.username=$PORG_DEV_APIADMIN_USER | .email=$PORG_DEV_APIADMIN_EMAIL | .first_name=$PORG_DEV_APIADMIN_FN | .last_name=$PORG_DEV_APIADMIN_LN | .password=$PORG_DEV_APIADMIN_PWD' \
#   > "${BUILD_DIR}/${PORG_DEV_APIADMIN_USER}.json"

# echo "  Creating the API Admin user ($PORG_DEV_APIADMIN_USER) in APIC using generated ${BUILD_DIR}/${PORG_DEV_APIADMIN_USER}.json file..."
# apic users:create --server $APIC_MGMT_SERVER --org $APIC_ADMIN_ORG --user-registry 'api-manager-lur' --format json ${BUILD_DIR}/${PORG_DEV_APIADMIN_USER}.json > ${BUILD_DIR}/${PORG_DEV_APIADMIN_USER}-create-output.json

# echo "  Get the URL for the API Admin user"
# PORG_DEV_APIADMIN_USER_URL=$(cat ${BUILD_DIR}/${PORG_DEV_APIADMIN_USER}-create-output.json | jq -r '.url')
# echo "  API Admin User URL - $PORG_DEV_APIADMIN_USER_URL"

# echo " "
# echo "Build Developer user create file and store in ${BUILD_DIR}/${PORG_DEV_DEVELOPER_USER}.json file..."
# jq -n \
#   --arg PORG_DEV_DEVELOPER_FN "$PORG_DEV_DEVELOPER_FN" \
#   --arg PORG_DEV_DEVELOPER_LN "$PORG_DEV_DEVELOPER_LN" \
#   --arg PORG_DEV_DEVELOPER_EMAIL "$PORG_DEV_DEVELOPER_EMAIL" \
#   --arg PORG_DEV_DEVELOPER_USER "$PORG_DEV_DEVELOPER_USER" \
#   --arg PORG_DEV_DEVELOPER_PWD "$PORG_DEV_DEVELOPER_PWD" \
#   '.username=$PORG_DEV_DEVELOPER_USER | .email=$PORG_DEV_DEVELOPER_EMAIL | .first_name=$PORG_DEV_DEVELOPER_FN | .last_name=$PORG_DEV_DEVELOPER_LN | .password=$PORG_DEV_DEVELOPER_PWD' \
#   > "${BUILD_DIR}/${PORG_DEV_DEVELOPER_USER}.json"

# echo "  Creating the Developer user ($PORG_DEV_DEVELOPER_USER) in APIC using generated ${BUILD_DIR}/${PORG_DEV_DEVELOPER_USER}.json file..."
# apic users:create --server $APIC_MGMT_SERVER --org $APIC_ADMIN_ORG --user-registry 'api-manager-lur' --format json ${BUILD_DIR}/${PORG_DEV_DEVELOPER_USER}.json > ${BUILD_DIR}/${PORG_DEV_DEVELOPER_USER}-create-output.json

# echo "  Get the URL for the Developer user"
# PORG_DEV_DEVELOPER_USER_URL=$(cat ${BUILD_DIR}/${PORG_DEV_DEVELOPER_USER}-create-output.json | jq -r '.url')
# echo "  Developer User URL - $PORG_DEV_DEVELOPER_USER_URL"

### gas comment END

#####################################################
# LOGOUT FROM APIC as Admin and login as pOrd Owner #
#####################################################
./apic-logout.sh

### gas commented this section - not needed for demo, left for future expansion
# ./apic-login-development.sh

# #####################################
# # Setup Email Notification for pOrg #
# #####################################
# echo " "
# echo "Build JSON to update email notification settings in Dev pORG and store in ${BUILD_DIR}/${PORG_DEV_NAME}-settings.json file..."
# jq -n \
#   --arg PORG_DEV_TITLE "$PORG_DEV_TITLE" \
#   --arg PORG_DEV_OWNER_EMAIL "$PORG_DEV_OWNER_EMAIL" \
#   '.email_sender.custom=true | .email_sender.name=$PORG_DEV_TITLE | .email_sender.address=$PORG_DEV_OWNER_EMAIL' \
#   > "${BUILD_DIR}/${PORG_DEV_NAME}-settings.json"

# echo "  Updating the pOrg ($PORG_DEV_TITLE) notification setting in APIC using generated ${BUILD_DIR}/${PORG_DEV_NAME}-settings.json file..."
# apic org-settings:update --server $APIC_MGMT_SERVER --org $PORG_DEV_NAME --format json ${BUILD_DIR}/${PORG_DEV_NAME}-settings.json > ${BUILD_DIR}/${PORG_DEV_NAME}-setting-output.json


# ################################################
# # Add pOrg users as members with correct roles #
# ################################################
# echo " "
# echo "Get the URL for the api-admin role"
# PORG_DEV_APIADMIN_ROLE_URL=$(apic roles:get --server $APIC_MGMT_SERVER --scope org --org $PORG_DEV_NAME --format json --fields url --output - api-administrator | jq -r '.url')
# echo "  API Admin Role URL = $PORG_DEV_APIADMIN_ROLE_URL"

# echo " "
# echo "Build API Admin member file and store in ${BUILD_DIR}/${PORG_DEV_APIADMIN_USER}-member.json file..."
# jq -n \
#   --arg PORG_DEV_APIADMIN_ROLE_URL "$PORG_DEV_APIADMIN_ROLE_URL" \
#   --arg PORG_DEV_APIADMIN_USER_URL "$PORG_DEV_APIADMIN_USER_URL" \
#   '.user.url=$PORG_DEV_APIADMIN_USER_URL | .role_urls=[$PORG_DEV_APIADMIN_ROLE_URL]' \
#   > "${BUILD_DIR}/${PORG_DEV_APIADMIN_USER}-member.json"

# echo "  Add the API Administrator member using the ${BUILD_DIR}/${PORG_DEV_APIADMIN_USER}-member.json file..."
# apic members:create --server $APIC_MGMT_SERVER --scope org --org $PORG_DEV_NAME --format json ${BUILD_DIR}/${PORG_DEV_APIADMIN_USER}-member.json > ${BUILD_DIR}/${PORG_DEV_APIADMIN_USER}-member-output.json

# echo "  Get the URL for the developer role"
# PORG_DEV_DEVELOPER_ROLE_URL=$(apic roles:get --server $APIC_MGMT_SERVER --scope org --org $PORG_DEV_NAME --format json --fields url --output - developer | jq -r '.url')
# echo "  Developer Role URL = $PORG_DEV_DEVELOPER_ROLE_URL"

# echo " "
# echo "Build Developer member file and store in ${BUILD_DIR}/${PORG_DEV_DEVELOPER_USER}-member.json file..."
# jq -n \
#   --arg PORG_DEV_DEVELOPER_ROLE_URL "$PORG_DEV_DEVELOPER_ROLE_URL" \
#   --arg PORG_DEV_DEVELOPER_USER_URL "$PORG_DEV_DEVELOPER_USER_URL" \
#   '.user.url=$PORG_DEV_DEVELOPER_USER_URL | .role_urls=[$PORG_DEV_DEVELOPER_ROLE_URL]' \
#   > "${BUILD_DIR}/${PORG_DEV_DEVELOPER_USER}-member.json"

# echo "  Add the Developer member using the ${BUILD_DIR}/${PORG_DEV_DEVELOPER_USER}-member.json file..."
# apic members:create --server $APIC_MGMT_SERVER --scope org --org $PORG_DEV_NAME --format json ${BUILD_DIR}/${PORG_DEV_DEVELOPER_USER}-member.json > ${BUILD_DIR}/${PORG_DEV_DEVELOPER_USER}-member-output.json

### gas comment END

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
