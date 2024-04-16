#!/bin/bash
export CPD_ROUTE=$(oc get route cpd -n cpd -o jsonpath="{.spec.host}")

export CPD_ADMIN_PASSWORD=$(oc get secret "admin-user-details" -n cpd -o jsonpath="{.data.initial_admin_password}"| base64 -d)

export CPD_TOKEN=$(curl -k --location --request POST "https://$CPD_ROUTE/v1/preauth/signin" --header 'Content-Type: application/json' --data-raw "{\"username\":\"admin\",\"password\":\"$CPD_ADMIN_PASSWORD\"}" | jq -r .token)

# check dmc state
curl -k --location --request POST "https://$CPD_ROUTE/zen-data/v1/addOn/query" \
--header "Authorization: Bearer $CPD_TOKEN" \
--header 'Content-Type: application/json' \
--data-raw '{
    "type": "dmc"
}' | jq .requestObj[0].State


# get dmc id
export DMC_ID=$(curl -k --location --request GET "https://$CPD_ROUTE/zen-data/v3/service_instances?fetch_all_instances=true" --header "Authorization: Bearer $CPD_TOKEN"  | jq -r '.service_instances[] | select(.addon_type =="dmc").id')

# get db2oltp id
export DB2OLT_ID=$(curl -k --location --request GET "https://$CPD_ROUTE/zen-data/v3/service_instances?fetch_all_instances=true" --header "Authorization: Bearer $CPD_TOKEN"  | jq -r '.service_instances[] | select(.addon_type =="db2oltp").id')

# get db2oltp display name - OTHERWISE IT NOT WORKS!!!!
export DB2OLT_DISPLAY_NAME=$(curl -k --location --request GET "https://$CPD_ROUTE/zen-data/v3/service_instances?fetch_all_instances=true" --header "Authorization: Bearer $CPD_TOKEN"  | jq -r '.service_instances[] | select(.addon_type =="db2oltp").display_name')


# get the db2 password
export DB2_PASSWORD=$(oc get secret "c-db2oltp-$DB2OLT_ID-instancepassword" -n cpd -o jsonpath="{.data.password}"| base64 -d)


curl -k --location --request POST "https://$CPD_ROUTE/addon-dmc/v1/profiles" \
--header "Authorization: Bearer $CPD_TOKEN" \
--header 'Content-Type: application/json' \
--data-raw "{
  \"CollectionCred\": {
    \"password\": \"$DB2_PASSWORD\",
    \"securityMechanism\": \"9\",
    \"user\": \"db2inst1\"
  },
  \"databaseName\": \"BLUDB\",
  \"dbInstanceId\": \"$DB2OLT_ID\",
  \"dbType\": \"db2oltp\",
  \"display_name\": \"$DB2OLT_DISPLAY_NAME\",
  \"dmcInstanceId\": \"$DMC_ID\",
  \"host\": \"c-db2oltp-$DB2OLT_ID-db2u\",
  \"plan\": \"smp\",
  \"port\": 50001,
  \"sslCertLocation\": \"/opt/ibm-datasrvrmgr/Config/cpd-internal-tls/ca.crt\",
  \"sslConnection\": true
}"