#!/bin/sh

/scripts/add-config.sh
/scripts/create-ca.sh
/scripts/create-certs.sh

rm ./cert.cnf
