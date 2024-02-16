#!/bin/bash
###################
# Setup Build Env #
###################
echo " "
echo "Setting up build environment..."
source ./apic-scripts-env-setup.sh

#################
# LOGIN TO APIC #
#################
./apic-login-admin.sh

################################
# Build Mail Server Definition #
################################
echo " "
echo "Building Mail Server Definition..."
echo "  Generating ${APIC_MAIL_SERVER}.json file"


jq -n --arg MAIL_SERVER_HOST "$MAIL_SERVER_HOST" \
    --argjson MAIL_SERVER_PORT "$MAIL_SERVER_PORT" \
    --arg APIC_MAIL_SERVER "$APIC_MAIL_SERVER" \
    '.type="mail_server" | .title=$APIC_MAIL_SERVER | .host=$MAIL_SERVER_HOST | .port=$MAIL_SERVER_PORT'\
    > "${APIC_MAIL_SERVER}.json"


######################################################
# Add New Mail Server Definition and Send Test Email #
######################################################
echo " "
echo "Creating Mail Server in APIC using generated ${APIC_MAIL_SERVER}.json file..."
apic mail-servers:create -s $APIC_MGMT_SERVER -o $APIC_ADMIN_ORG --format json "${APIC_MAIL_SERVER}.json" > ${APIC_MAIL_SERVER}-create-output.json

echo "  Testing Connection to Mail Server just created in APIC..."
echo "  Generate Test Email Recipient File"
jq -n --arg email "test@${CUSTOMER_NAME}.com" '{"recipients": [$email]}'\
  > "${CUSTOMER_NAME}-mail-test.json"

echo "  Test Nofication will be sent to - test@${CUSTOMER_NAME}.com"
apic mail-servers:test-connection --server $APIC_MGMT_SERVER --org $APIC_ADMIN_ORG --format json ${APIC_MAIL_SERVER} ${CUSTOMER_NAME}-mail-test.json

#################################################
# Update Cloud Settings to use new Email Server #
#################################################
echo " "
echo "Get current cloud settings and store in cloud-settings-original.json file..."
apic cloud-settings:get -s $APIC_MGMT_SERVER --format json --fields mail_server_url --output - > cloud-setting-ms-original.json

echo "  Get the URL for the new mail server..."
MAIL_SERVER_URL=$(cat ${APIC_MAIL_SERVER}-create-output.json | jq -r '.url')
echo "  New Mail Server URL - $MAIL_SERVER_URL"

echo "  Update New Mail Server URL and save in cloud-settings-ms-updated.json file"
jq --arg MAIL_SERVER_URL "$MAIL_SERVER_URL" \
  '.mail_server_url=$MAIL_SERVER_URL'\
  cloud-setting-ms-original.json > "cloud-setting-ms-updated.json"

echo "  Add the New Mail Server to the cloud settings in APIC"
apic cloud-settings:update -s $APIC_MGMT_SERVER --format json cloud-setting-ms-updated.json > cloud-setting-update-output.json
