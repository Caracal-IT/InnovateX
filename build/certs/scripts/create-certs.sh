#!/bin/sh

. /scripts/utilities.sh

CONFIG='./cert.cnf'

echo2  "Creating Certificates"

echo2 "Creating CSR"
openssl req                                             \
    -new                                                \
    -x509                                               \
    -nodes                                              \
    -days 365                                           \
    -CA ca.pem                                          \
    -CAkey ca.key                                       \
    -newkey rsa:2048                                    \
    -keyout $CERT_NAME.key                              \
    -out $CERT_NAME.crt                                 \
    -config $CONFIG                                     \
    -passin pass:$CERT_PASSWORD                         \
    -passout pass:$CERT_PASSWORD                        \

echo2 "Creating PFX"
openssl pkcs12                                         \
    -inkey $CERT_NAME.key                              \
    -in $CERT_NAME.crt                                 \
    -export -out $CERT_NAME.pfx                        \
    -passin pass:$CERT_PASSWORD                        \
    -passout pass:$CERT_PASSWORD                       \
    
echo2 "Creating RSA"
openssl pkcs12                                         \
    -in $CERT_NAME.pfx                                 \
    -nocerts                                           \
    -nodes                                             \
    -out $CERT_NAME.rsa                                \
    -passin pass:$CERT_PASSWORD                        \

echo2 "Creating PEM"
openssl pkcs12                                         \
    -in $CERT_NAME.pfx                                 \
    -out $CERT_NAME.pem                                \
    -nodes                                             \
    -passin pass:$CERT_PASSWORD                        \
    
chmod 644 $CERT_NAME.pem

echo2 "Certificates created successfully"
