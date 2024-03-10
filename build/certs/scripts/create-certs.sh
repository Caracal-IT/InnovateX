#!/bin/sh

. /scripts/utilities.sh
ORANGE='\033[1;36m'
NC='\033[0m' # No Color

echo2  "Creating Certificates"

cat >> /dist/some.text << 'END'
some stuff here!!
more stuff
END

echo2 "Certs Certificates"
