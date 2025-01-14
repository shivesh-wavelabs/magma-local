#!/usr/bin/env bash

set -e

CONTROLLER_IMAGE="shiveshwavelabs/controller"
CONTROLLER_TAG="master-feb"
DOMAIN_NAME=magmalocal.com
CERTS_CHART=true

# upgrade -i
# template --debug --dry-run

helm upgrade -i orc8r orc8r/cloud/helm/orc8r \
  --set nginx.image.repository=shiveshwavelabs/nginx \
  --set nginx.image.tag=master-feb \
  --set nginx.spec.hostname=controller.${DOMAIN_NAME} \
  --set nms.certs.enabled=${CERTS_CHART} \
  --set certs.domainName=${DOMAIN_NAME} \
  --set certs.enabled=${CERTS_CHART} \
  --set certs.create=${CERTS_CHART} \
  --set metrics.enabled=true \
  --set controller.podDisruptionBudget.enabled=true \
  --set secrets.create=true \
  --set secrets.docker.registry=docker.io \
  --set secrets.docker.username=username \
  --set secrets.docker.password=password

declare -A orc8r_helm_charts

orc8r_helm_charts=(
  [lte-orc8r]="lte/cloud/helm/lte-orc8r"
  [feg-orc8r]="feg/cloud/helm/feg-orc8r"
  [cwf-orc8r]="cwf/cloud/helm/cwf-orc8r"
  [wifi-orc8r]="wifi/cloud/helm/wifi-orc8r"
  [fbinternal-orc8r]="fbinternal/cloud/helm/fbinternal-orc8r"
)

for orc8r_chart in "${!orc8r_helm_charts[@]}"
do 
  helm upgrade -i ${orc8r_chart} ${orc8r_helm_charts[${orc8r_chart}]} \
    --set controller.image.repository=${CONTROLLER_IMAGE} \
    --set controller.image.tag=${CONTROLLER_TAG} \
    --set certs.enabled=${CERTS_CHART}
done
