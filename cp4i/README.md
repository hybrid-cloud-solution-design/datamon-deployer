
Installation steps for the CP4i
-------------------------------

CP4I is required component for the CPI Connect inatallation.

Currently there is no "Deployer pipeline" to install latest version of the CP4I

You need to manually create catalog sources:
- ibm-cp-common-services-4.3.1
- ibm-apiconnect-5.1.0
- ibm-datapower-operator-1.9.0
- ibm-integration-platform-navigator-7.2.0


Install operators:
https://www.ibm.com/docs/en/cloud-paks/cp-integration/2023.4?topic=images-adding-catalog-sources-cluster

Required operators:
- common-services-4.3.1
- platform-navigator
- datapower
- apiconnect

You also need Certificate Manager operator, but one maybe already installed on the cluster.

Operators need to be installed in the separate, single namespace to prevent collisions with CP4D operators.


# CP4I link
oc get consolelink | findstr "IBM Cloud Pak for Integration"
integration-console-link-ibm-integration-platform-navigator   IBM Cloud Pak for Integration [integration]     https://integration-quickstart-pn-integration.apps.6593e9e3151f6e0011ac73a6.cloud.techzone.ibm.com          27m


User:
integration-admin
Password:
https://www.ibm.com/docs/en/cloud-paks/cp-integration/2023.4?topic=management-getting-initial-administrator-password
NAMESPACE=integration
oc get secret integration-admin-initial-temporary-credentials -n "${NAMESPACE}" -o jsonpath='{.data.password}' | base64 --decode


# Create pull secret with entitlement key
https://www.ibm.com/docs/en/cloud-paks/cp-integration/2023.4?topic=fayekoi-finding-applying-your-entitlement-key-by-using-cli-online-installation


```
oc create secret docker-registry ibm-entitlement-key \
    --docker-username=cp \
    --docker-password=entitlement_key \
    --docker-server=cp.icr.io \
    --namespace=target_namespace
```