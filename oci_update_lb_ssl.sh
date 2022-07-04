#!/bin/bash

OCI_CLI=/root/bin/oci

# Import Config
cd $(dirname "$0")
. oci_update_lb_ssl.conf
. output_log.sh

# Redirect stdout
exec 2> ${LOGFILE}

# Check Certificates
ls ${private_key_file}
if [ ${?} -ne 0 ]; then
    log "not fount ${private_key_file}"
    exit 1
fi

ls ${public_certificate_file}
if [ ${?} -ne 0 ]; then
    log "not fount ${public_certificate_file}"
    exit 1
fi


# Create OCI Certificates
certificate_name="letsencrypt-$(date +"%Y%m%d")"

${OCI_CLI} lb certificate create \
    --certificate-name ${certificate_name} \
    --load-balancer-id ${load_balancer_id} \
    --private-key-file ${private_key_file} \
    --public-certificate-file ${public_certificate_file} \
    --wait-for-state "SUCCEEDED" \
    --auth instance_principal

if [ ${?} -e 0 ]; then
    log "SUCCEEDED Create OCI Certificates (${certificate_name})"
fi

# Update OCI Load Balancer Listener
${OCI_CLI} lb listener update \
    --default-backend-set-name ${default_backend_set_name} \
    --listener-name ${listener_name} \
    --load-balancer-id ${load_balancer_id} \
    --port ${port} \
    --protocol ${protocol} \
    --routing-policy-name ${routing_policy_name} \
    --ssl-certificate-name ${certificate_name} \
    --wait-for-state "SUCCEEDED" \
    --cipher-suite-name 'oci-default-http2-ssl-cipher-suite-v1' \
    --force \
    --auth instance_principal

if [ ${?} -e 0 ]; then
    log "SUCCEEDED Update OCI Load Balancer Listener (${listener_name})"
fi

# Delete old Certificate
old_certificate_name=$(${OCI_CLI} lb certificate list \
    --load-balancer-id ${load_balancer_id} \
    --auth instance_principal \
    | jq '.data[1]."certificate-name"'
)

${OCI_CLI} lb certificate delete \
    --certificate-name ${old_certificate_name} \
    --load-balancer-id ${load_balancer_id} \
    --wait-for-state "SUCCEEDED" \
    --force \
    --auth instance_principal \

if [ ${?} -e 0 ]; then
    log "SUCCEEDED Delete old Certificate (${old_certificate_name})"
fi