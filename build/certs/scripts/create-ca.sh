#!/bin/sh

. /scripts/utilities.sh

CONFIG='./cert.cnf'

echo2 "Creating CA"
openssl req                                             \
-new                                                    \
-x509                                                   \
-days 365                                               \
-extensions v3_ca                                       \
-keyout ca.key                                          \
-out ca.pem                                             \
-config $CONFIG                                         \
-passin pass:$CERT_PASSWORD                             \
-passout pass:$CERT_PASSWORD                            \
