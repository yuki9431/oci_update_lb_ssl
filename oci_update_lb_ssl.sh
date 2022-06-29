#!/bin/bash

OCI_CLI=/root/bin/oci

# Import Config
cd $(dirname "$0")
. oci_update_lb_ssl.conf

# certbot
# SSL証明書を取得

# TODO

# Create OCI Certificates

# TODO

# Update OCI Load Balancer Listeners
${OCI_CLI} lb listener update \
    --default-backend-set-name ${default-backend-set-name} \
    --listener-name ${listener-name} \
    --load-balancer-id ${load-balancer-id}
    --port ${port} \
    --protocol ${protocol} \
    --routing-policy-name ${routing-policy-name} \
    --ssl-certificate-name ${ssl-certificate-name} \
    --wait-for-state "SUCCEEDED"
    --force \