#!/bin/sh

content=$(cat << EOF
[req]
prompt = no
distinguished_name = dn
x509_extensions = v3_req
req_extensions = v3_req


[req_distinguished_name]
countryName = Country Name (2 letter code)
countryName_default = ZA
stateOrProvinceName = State or Province Name (full name)
stateOrProvinceName_default = Western Cape
localityName = Locality Name (eg, city)
localityName_default = Cape Town
organizationName = Organization Name (eg, company)
organizationName_default = Caracal
commonName = Common Name (e.g. server FQDN or YOUR name)
commonName_default = $CERT_NAME
commonName_max = 64

[dn]
C = ZA
ST = Western Cape
L = Cape Town
O = Caracal
OU = Software
emailAddress = info@caracal.com
CN = $CERT_NAME

[v3_req]
keyUsage = critical, digitalSignature, keyAgreement
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = dev.caracal.com
DNS.3 = qa.caracal.com
DNS.4 = 127.0.0.1
DNS.4 = host.docker.internal
DNS.5 = $CERT_NAME

[v3_ca]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = CA:true
EOF
)

# Write the content to the file
echo "$content" > "./cert.cnf"