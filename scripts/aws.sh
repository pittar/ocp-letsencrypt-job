#!/usr/bin/env bash

if [[ -z "${STAGING}" ]]; then
    echo "STAGING environment variable must be set to 'true' or 'false'."
    exit 1
fi

# Get apps wildcard domain.
LE_WILDCARD=$(oc get ingresscontroller default -n openshift-ingress-operator -o jsonpath='{.status.domain}')
echo "LE_WILDCARD: $LE_WILDCARD"

# From wildcard domain, determine the api url.
LE_API=$( echo "$LE_WILDCARD" | cut -d'.' -f2- )
LE_API="api.$LE_API"
echo "API: $LE_API"

issue_args=(
    --install
    --dns dns_aws
    -d "$LE_API"
    -d "*.$LE_WILDCARD"
    --home "$ACME_HOME"
    --cert-home "$CERT_HOME"
    --config-home "$CONFIG_HOME"
    --debug
)
if [ "$STAGING" == true ] ; then
    issue_args+=(--staging)
fi

# Issue certs.
acme.sh "${issue_args[@]}"

install_args=(
    --install-cert
    -d "$LE_API"
    -d "*.$LE_WILDCARD"
    --cert-file "$FINAL_CERTS/cert.pem"
    --key-file "$FINAL_CERTS/key.pem"
    --fullchain-file "$FINAL_CERTS/fullchain.pem"
    --ca-file "$FINAL_CERTS/ca.cer"
    --home "$ACME_HOME"
    --cert-home "$CERT_HOME"
    --config-home "$CONFIG_HOME"
    --debug
)
if [ "$STAGING" == true ] ; then
    install_args+=(--staging)
fi

# Add --staging to debug
if [ "$STAGING" == true ] ; then
    acme.sh --install-cert -d $LE_API -d *.$LE_WILDCARD --cert-file $FINAL_CERTS/cert.pem --key-file $FINAL_CERTS/key.pem --fullchain-file $FINAL_CERTS/fullchain.pem --ca-file $FINAL_CERTS/ca.cer --home acme-home --cert-home cert-home --config-home config-home
fi

# Run install.
acme.sh "${install_args[@]}"

secret_args=(
    create
    secret
    tls
    router-certs
    --cert="$FINAL_CERTS/fullchain.pem"
    --key="$FINAL_CERTS/key.pem"
    -n openshift-ingress
)
if [ "$STAGING" == true ] ; then
    install_args+=(--dry-run=true)
    install_args+=(-o yaml)
fi

# Create tls secret.  Only dry-run and ouptut yaml if STAGING.
oc "${secret_args[@]}"

# Patch ingress with new secret if NOT STAGING.
if [ "$STAGING" == false ] ; then
    oc patch ingresscontroller default -n openshift-ingress-operator --type=merge --patch='{"spec": { "defaultCertificate": { "name": "router-certs" }}}'
fi