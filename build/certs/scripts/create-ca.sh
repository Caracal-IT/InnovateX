
CERT_NAME='caracal-server-dev'
CONFIG='/scripts/cert.cnf'

#
# Generate CA private key and self-signed certificate
#
echo ----------------------------------------------------
openssl req                                             \
-new                                                    \
-x509                                                   \
-days 365                                               \
-extensions v3_ca                                       \
-keyout server-ca.key                                   \
-out server-ca.pem                                      \
-config $CONFIG                                         \
-passin pass:$CERT_PASSWORD                             \
-passout pass:$CERT_PASSWORD                            \

#
# CREATE THE CERTIFICATE SIGNING REQUEST (CSR)
#
echo ----------------------------------------------------
openssl req                                             \
    -new                                                \
    -x509                                               \
    -nodes                                              \
    -days 365                                           \
    -CA server-ca.pem                                   \
    -CAkey server-ca.key                                \
    -newkey rsa:2048                                    \
    -keyout $CERT_NAME.key                              \
    -out $CERT_NAME.crt                                 \
    -config $CONFIG                                     \
    -passin pass:$CERT_PASSWORD                         \
    -passout pass:$CERT_PASSWORD                        \

#
# CONVERT TO PFX
#
echo ---------------------------------------------------
openssl pkcs12                                         \
    -inkey $CERT_NAME.key                              \
    -in $CERT_NAME.crt                                 \
    -export -out $CERT_NAME.pfx                        \
    -passin pass:$CERT_PASSWORD                        \
    -passout pass:$CERT_PASSWORD                       \
    
#
# CREATE RSA
#   
echo ---------------------------------------------------
openssl pkcs12                                         \
    -in $CERT_NAME.pfx                                 \
    -nocerts                                           \
    -nodes                                             \
    -out $CERT_NAME.rsa                                \
    -passin pass:$CERT_PASSWORD                        \

#
# CREATE PEM
#   
echo ---------------------------------------------------
openssl pkcs12                                         \
    -in $CERT_NAME.pfx                                 \
    -out $CERT_NAME.pem                                \
    -nodes                                             \
    -passin pass:$CERT_PASSWORD                        \
    
chmod 644 $CERT_NAME.pem