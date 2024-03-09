#!/bin/sh

. /scripts/utilities.sh
ORANGE='\033[1;36m'
NC='\033[0m' # No Color

echo  -e "${ORANGE}Creating certs for the following domains:${NC}"
echo -e "${ORANGE} PASSWORD  - ${CERT_PASSWORD}${NC}"

ls