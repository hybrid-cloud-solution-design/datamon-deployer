# Run Scripts to set up APIC Env

## Pre-requisites
Make sure you have these tools available:
- apic toolkit [Link](https://www.ibm.com/docs/en/api-connect/10.0.x?topic=configuration-installing-toolkit)
- accept apic licences using `apic licenses` command
- jq 
- yq 

## Create Mail Server Definition and Make it default for notifications.

Run `./apic-setup-notifications.sh`

See `apic-mail` exists at `Cloud Manager > Resources > Notifications`

See `Cloud Manager > Settings > Notifications > Email Server` is set to `apic-mail`

See test message email is in Mail Dev inbox

## Set API Manager LUR Visibility to Public

Run `./apic-user-registry-visibility.sh`

see `Cloud Manager > Resources > User Registries > API Manager Local User Registry > Visible to` is set to `Public`

## Create Dev pOrg

Run `./apic-porg-dev.sh`

Check Org and Owner at `Cloud Manager > Provider Organisations`

Login to API Manager as pOrg owner

- user: esgadmin 
- pwd: (PORG_DEV_OWNER_PWD) eg `passw0rd`

<!-- Check `API Manager > Settings > Notifications`

- Name
- Email

Check `API Manager > Members`

- marshall - Developer
- greg - API Administrator
- dev.org-owner - Org Owner

Check can log into API Manager as following users

- marshall
- greg -->

## Add Dev Catalog

Run `./apic-catalog-dev.sh`

Login to API Manager as pOrg owner

- user: (PORG_DEV_OWNER_USER)) eg `esgadmin`
- pwd: (PORG_DEV_OWNER_PWD) eg `passw0rd`

Check ESG Portfolio Analysis catalog created `API Manager > Manage`

Check Catalog Settings:

- `API Manager > Manage > ESG Portfolio Analysis > Catalog settings > Portal`
<!-- - `API Manager > Manage > ESG Portfolio Analysis > Catalog settings > Lifecycle approvals` -->

## Add Dev Corg

Run `./apic-corg-dev.sh`

Login to API Manager as pOrg owner

- user: (PORG_DEV_OWNER_USER) eg `dev.org-owner@tiger-bank.com`
- pwd: (PORG_DEV_OWNER_PWD) eg `passw0rd`

Check cOrg catalog created `API Manager > Manage > Mortgages > Consumers`

- BMB Mortgages Dev
  - Owner `gary`

Log into Dev Portal as owner (`gary`)

- Check organisation

Log into Dev Portal as member (`sonya`)

- Check organisation

## Create Prod pOrg

Run `./apic-porg-prod.sh`

Check Org and Owner at `Cloud Manager > Provider Organisations`

Login to API Manager as pOrg owner

- user: (${PORG_PROD_OWNER_FN}.${PORG_PROD_OWNER_LN}@${CUSTOMER_NAME}.com) eg `prod.org-owner@tiger-bank.com`
- pwd: (PORG_PROD_OWNER_PWD) eg `passw0rd`

Check `API Manager > Settings > Notifications`

- Name
- Email

Check `API Manager > Settings > Roles`

- publish-requestor

Check `API Manager > Members`

- greg - publish-requestor
- barry - API Administrator
- prod.org-owner - Org Owner

Check can log into API Manager as following users

- barry
- greg

## Add Prod Catalog

Run `./apic-catalog-prod.sh`

Login to API Manager as pOrg owner

- user: (${PORG_PROD_OWNER_FN}.${PORG_PROD_OWNER_LN}@${CUSTOMER_NAME}.com) eg `prod.org-owner@tiger-bank.com`
- pwd: (PORG_PROD_OWNER_PWD) eg `passw0rd`

Check Mortgages catalog created `API Manager > Manage`

Check Catalog Settings:

- `API Manager > Manage > Mortgages > Catalog settings > Portal`
- `API Manager > Manage > Mortgages > Catalog settings > Lifecycle approvals`

## Add Prod Corgs

Run `./apic-corg-prod.sh`

Login to API Manager as pOrg owner

- user: (${PORG_PROD_OWNER_FN}.${PORG_PROD_OWNER_LN}@${CUSTOMER_NAME}.com) eg `prod.org-owner@tiger-bank.com`
- pwd: (PORG_PROD_OWNER_PWD) eg `passw0rd`

Check cOrg catalog created `API Manager > Manage > Mortgages > Consumers`

- BMB Mortgages Prod
  - Owner `gary`
- RTB Live Proving
  - Owner `george`

Log into Prod Portal as owner (`gary`)

- Check organisation

Log into Prod Portal as member (`sonya`)

- Check organisation

Log into Prod Portal as owner (`george`)

- Check organisation

## Setup Demo Artefacts

### Draft APIs (Helloworld) in DEV

run `./apic-apis-import-dev.sh`

Login to API Manager as API Manager

- user: greg@iwatest.com
- pwd: passw0rd

Check 3 versions of helloworld APIs exist `API Manager > Develop > APIs`
Check 3 versions of helloworld Products exist `API Manager > Develop > Products`

Test the APIs call the correct backend with API Manager by going into the API putting it `online` and running test

**NOTE: ACE Integration server called `is-hello-world` must exist in the `ace` namespace.**

### Publish APIs and Products (Helloworld) in DEV

run `./apic-products-publish-dev.sh`

Log into the developer portal and run a test for each version of the Helloworld App/Product APIs

Then manually put the products into different states by

Login to API Manager as API Manager

- user: greg@tiger-bank.com
- pwd: passw0rd

1. `retire` helloworld-product v1.0. Approve `retirement` from `tasks` tab
2. `replace` helloworld-product v1.1 with helloworld-product v1.2. **DO NOT APPROVE SO THAT THE DIFFERENT PENDING STATES ARE SHOWN**

### Draft APIs (mortgageBalances) in PROD

run `./apic-apis-import-prod.sh`

Login to API Manager as API Manager

- user: barry@tiger-bank.com
- pwd: passw0rd

Check APIs at `API Manager > Develop > APIs`

- Mortgage Balance API mortgage-balance-api 1.0
- Mortgage Balance API mortgage-balance-api 1.1
- Mortgage Balance API Istio mortgage-balance-api-istio 1.1
- Mortgage Balance API Istio mortgage-balance-api-istio 1.0
- Mortgage Balance API Istio LP mortgage-balance-api-istio-lp 1.1
- Mortgage Balance API Knative mortgage-balance-api-knative 1.0

Check Products at `API Manager > Develop > Products`

- Mortgage Balance Product mortgage-balance-product 1.0
- Mortgage Balance Product mortgage-balance-product 1.1
- Mortgage Balance Product Istio mortgage-balance-product-istio 1.1
- Mortgage Balance Product Istio mortgage-balance-product-istio 1.0
- Mortgage Balance Product Istio LP mortgage-balance-api-istio-lp 1.1
- Mortgage Balance Product Knative mortgage-balance-product-knative 1.0

Test the APIs call the correct backend with API Manager by going into the API putting it `online` and running test

### Publish APIs and Products (Helloworld) in PROD

run `./apic-products-publish-prod.sh`

Log into the developer portal and run a test for each version of the Helloworld App/Product APIs
