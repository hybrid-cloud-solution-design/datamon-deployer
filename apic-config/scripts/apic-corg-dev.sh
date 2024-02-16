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
# LOGIN TO Development cOrg #
#############################
./apic-login-development.sh

######################################
# Create Owner for Dev Consumer cOrg #
######################################
echo " "
echo "Build Dev cOrg owner update file and store in ${BUILD_DIR}/${CORG_DEV_NAME}-owner.json file..."
jq -n \
  --arg CORG_DEV_OWNER_FN "$CORG_DEV_OWNER_FN" \
  --arg CORG_DEV_OWNER_LN "$CORG_DEV_OWNER_LN" \
  --arg CORG_DEV_OWNER_EMAIL "$CORG_DEV_OWNER_EMAIL" \
  --arg CORG_DEV_OWNER_USER "$CORG_DEV_OWNER_USER" \
  --arg CORG_DEV_OWNER_PWD "$CORG_DEV_OWNER_PWD" \
  '.username=$CORG_DEV_OWNER_USER | .email=$CORG_DEV_OWNER_EMAIL | .first_name=$CORG_DEV_OWNER_FN | .last_name=$CORG_DEV_OWNER_LN | .password=$CORG_DEV_OWNER_PWD' \
  > "${BUILD_DIR}/${CORG_DEV_NAME}-owner.json"

echo "  Creating the cOrg owner ($CORG_DEV_OWNER_USER) in APIC using generated ${BUILD_DIR}/${CORG_DEV_NAME}-owner.json file..."
apic users:create --server $APIC_MGMT_SERVER --org $PORG_DEV_NAME --user-registry ${CAT_DEV_NAME}-catalog --format json ${BUILD_DIR}/${CORG_DEV_NAME}-owner.json > ${BUILD_DIR}/${CORG_DEV_NAME}-owner-create-output.json

echo "  Get the URL for the Owner user"
CORG_DEV_OWNER_USER_URL=$(cat ${BUILD_DIR}/${CORG_DEV_NAME}-owner-create-output.json | jq -r '.url')
echo "  Owner User URL - $CORG_DEV_OWNER_USER_URL"

echo " "
echo "Build Dev cOrg file and store in ${BUILD_DIR}/${CORG_DEV_NAME}.json file..."
jq -n \
  --arg CORG_DEV_TITLE "$CORG_DEV_TITLE" \
  --arg CORG_DEV_NAME "$CORG_DEV_NAME" \
  --arg CORG_DEV_OWNER_USER_URL "$CORG_DEV_OWNER_USER_URL" \
  '.title=$CORG_DEV_TITLE | .name=$CORG_DEV_NAME | .owner_url=$CORG_DEV_OWNER_USER_URL' \
  > "${BUILD_DIR}/${CORG_DEV_NAME}.json"

echo " "
echo "Creating the cOrg ($CORG_DEV_TITLE) in APIC using generated ${BUILD_DIR}/${CORG_DEV_NAME}.json file..."
apic consumer-orgs:create --server $APIC_MGMT_SERVER --org $PORG_DEV_NAME --catalog ${CAT_DEV_NAME} --format json ${BUILD_DIR}/${CORG_DEV_NAME}.json > ${BUILD_DIR}/${CORG_DEV_NAME}-create-output.json

# ########################################
# # Create Development cOrg Member Users #
# ########################################
# echo " "
# echo "Build Member user create file and store in ${BUILD_DIR}/${CORG_DEV_NAME}-user.json file..."
# jq -n \
#   --arg CORG_DEV_MEMBER_FN "$CORG_DEV_MEMBER_FN" \
#   --arg CORG_DEV_MEMBER_LN "$CORG_DEV_MEMBER_LN" \
#   --arg CORG_DEV_MEMBER_EMAIL "$CORG_DEV_MEMBER_EMAIL" \
#   --arg CORG_DEV_MEMBER_USER "$CORG_DEV_MEMBER_USER" \
#   --arg CORG_DEV_MEMBER_PWD "$CORG_DEV_MEMBER_PWD" \
#   '.username=$CORG_DEV_MEMBER_USER | .email=$CORG_DEV_MEMBER_EMAIL | .first_name=$CORG_DEV_MEMBER_FN | .last_name=$CORG_DEV_MEMBER_LN | .password=$CORG_DEV_MEMBER_PWD' \
#   > "${BUILD_DIR}/${CORG_DEV_NAME}-user.json"

# echo "  Creating the Member user ($CORG_DEV_MEMBER_USER) in APIC using generated ${BUILD_DIR}/${CORG_DEV_NAME}-user.json file..."
# apic users:create --server $APIC_MGMT_SERVER --org $PORG_DEV_NAME --user-registry ${CAT_DEV_NAME}-catalog --format json ${BUILD_DIR}/${CORG_DEV_NAME}-user.json > ${BUILD_DIR}/${CORG_DEV_NAME}-user-create-output.json

# echo "  Get the URL for the Member user"
# CORG_DEV_MEMBER_USER_URL=$(cat ${BUILD_DIR}/${CORG_DEV_NAME}-user-create-output.json | jq -r '.url')
# echo "  Member User URL - $CORG_DEV_MEMBER_USER_URL"

# ################################################
# # Add cOrg users as members with correct roles #
# ################################################
# echo " "
# echo "Get the URL for the developer role"
# PORG_DEV_DEVELOPER_ROLE_URL=$(apic roles:get --server $APIC_MGMT_SERVER --scope consumer-org --org $PORG_DEV_NAME --consumer-org ${CORG_DEV_NAME} --catalog ${CAT_DEV_NAME} --format json --fields url --output - developer | jq -r '.url')
# echo "  Developer Role URL = $PORG_DEV_DEVELOPER_ROLE_URL"

# echo "  Build Developer member file and store in ${BUILD_DIR}/${CORG_DEV_NAME}-member.json file..."
# jq -n \
#   --arg PORG_DEV_DEVELOPER_ROLE_URL "$PORG_DEV_DEVELOPER_ROLE_URL" \
#   --arg CORG_DEV_MEMBER_USER_URL "$CORG_DEV_MEMBER_USER_URL" \
#   '.user.url=$CORG_DEV_MEMBER_USER_URL | .role_urls=[$PORG_DEV_DEVELOPER_ROLE_URL]' \
#   > "${BUILD_DIR}/${CORG_DEV_NAME}-member.json"

# echo "  Add the Developer member using the ${BUILD_DIR}/${CORG_DEV_NAME}-member.json file..."
# apic members:create --server $APIC_MGMT_SERVER --scope consumer-org --org $PORG_DEV_NAME --consumer-org ${CORG_DEV_NAME} --catalog ${CAT_DEV_NAME} --format json ${BUILD_DIR}/${CORG_DEV_NAME}-member.json > ${BUILD_DIR}/${CORG_DEV_NAME}-member-output.json
# echo "  Result stored in ${BUILD_DIR}/${CORG_DEV_NAME}-member-output.json file"


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
