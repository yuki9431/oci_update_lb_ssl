#!/bin/bash

OCI_CLI=/root/bin/oci

# Import Config
cd $(dirname "$0")
. oci_update_lb_ssl.conf
. output_log.sh

# Redirect stdout
exec 2> ${LOGFILE}

# Check Certificates
if [ -e ${private_key_file} ]; then
  log "not fount ${private_key_file}"
  exit 1
fi

if [ -e ${public_certificate_file} ]; then
  log "not fount ${public_certificate_file}"
  exit 1
fi


# Create OCI Certificates
certificate-name="letsencrypt-$(date +"%Y%m%d")"

${OCI_CLI} lb certificate create \
    --certificate-name ${certificate-name} \
    --load_balancer_id ${load_balancer_id} \
    --private_key_file ${private_key_file}
    --public_certificate_file ${public_certificate_file}
    --wait-for-state "SUCCEEDED"


# Update OCI Load Balancer Listeners
${OCI_CLI} lb listener update \
    --default_backend_set_name ${default_backend_set_name} \
    --listener_name ${listener_name} \
    --load_balancer_id ${load_balancer_id}
    --port ${port} \
    --protocol ${protocol} \
    --routing_policy_name ${routing_policy_name} \
    --ssl_certificate_name ${certificate-name} \
    --wait-for-state "SUCCEEDED"
    --force \

    # TODO #1 Delete old Certificates