export BUILD_TIDY_UP=false
export BUILD_DIR="apic-build"

export APIC_NAMESPACE="integration"
# path to apic tool
export PATH=$PATH:/e/tmp/richard/toolkit
# 
export APIC_MGMT_SERVER=$(oc get route -l app.kubernetes.io/name=platform-api-endpoint -n $APIC_NAMESPACE -o jsonpath="{.items[].spec.host}")
# to find provider run, scope can be either admin or provider
# apic identity-providers:list --scope admin --server $APIC_MGMT_SERVER --fields name,title
# Default APIC variables
export APIC_ADMIN_REALM="admin/default-idp-1"
export APIC_PROVIDER_REALM="provider/default-idp-2"
export APIC_ADMIN_ORG="admin"
export APIC_ADMIN_USER=admin
#   
export APIC_PWD=$(oc get secret "api-management-mgmt-admin-pass" -n $APIC_NAMESPACE -o jsonpath="{.data.password}"| base64 -d)
export APIC_INST_NAME="api-management"

# mail server
export APIC_MAIL_SERVER="apic-mail"
export MAIL_SERVER_HOST="mailserver.development-mailserver"
export MAIL_SERVER_PORT=1025

#### Custom specific variables
export CUSTOMER_NAME=esg-demo

# provider org
#### DEV ARTIFACTS
##### Provider Org
export PORG_DEV_TITLE="ESG Development"
export PORG_DEV_NAME=$(echo ${PORG_DEV_TITLE// /-} | awk '{print tolower($0)}')

export PORG_DEV_OWNER_FN="esg"
export PORG_DEV_OWNER_LN="admin"
export PORG_DEV_OWNER_EMAIL="${PORG_DEV_OWNER_FN}.${PORG_DEV_OWNER_LN}@${CUSTOMER_NAME}.com"
export PORG_DEV_OWNER_USER="esgadmin"
export PORG_DEV_OWNER_PWD="passw0rd"

export CAT_DEV_TITLE="ESG Portfolio Analysis"
export CAT_DEV_NAME=$(echo ${CAT_DEV_TITLE// /-} | awk '{print tolower($0)}')


##### Consumer Org
export CORG_DEV_TITLE="Consumer Dev"
export CORG_DEV_NAME=$(echo ${CORG_DEV_TITLE// /-} | awk '{print tolower($0)}')

export CORG_DEV_OWNER_FN="developer1"
export CORG_DEV_OWNER_LN="${CUSTOMER_NAME}"
export CORG_DEV_OWNER_EMAIL="${CORG_DEV_OWNER_FN}@${CUSTOMER_NAME}.com"
export CORG_DEV_OWNER_USER="developer1"
export CORG_DEV_OWNER_PWD="passw0rd"
