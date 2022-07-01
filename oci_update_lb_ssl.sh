#!/bin/bash

OCI_CLI=/root/bin/oci

# Import Config
cd $(dirname "$0")
. oci_update_lb_ssl.conf
. output_log.sh

# Redirect stdout
exec 2> ${LOGFILE}

# Check Certificates
if [ -e ${private-key-file} ]; then
  log "not fount ${private-key-file}"
  exit 1
fi

if [ -e ${public-certificate-file} ]; then
  log "not fount ${public-certificate-file}"
  exit 1
fi


# Create OCI Certificates
certificate-name="letsencrypt-$(date +"%Y%m%d")"

${OCI_CLI} lb certificate create \
    --certificate-name ${certificate-name} \
    --load-balancer-id ${load-balancer-id} \
    --private-key-file ${private-key-file}
    --public-certificate-file ${public-certificate-file}
    --wait-for-state "SUCCEEDED"


# Update OCI Load Balancer Listeners
${OCI_CLI} lb listener update \
    --default-backend-set-name ${default-backend-set-name} \
    --listener-name ${listener-name} \
    --load-balancer-id ${load-balancer-id}
    --port ${port} \
    --protocol ${protocol} \
    --routing-policy-name ${routing-policy-name} \
    --ssl-certificate-name ${certificate-name} \
    --wait-for-state "SUCCEEDED"
    --force \

    # TODO #1 Delete old Certificates