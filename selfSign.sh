#!/bin/bash

# Self-signed SSL key generation script

me="$(basename $0) ->"

if [ -z "$1" ]; then
	echo "Generates a self-signed SSL certificate for a service or application."
	echo "Usage: $(basename $0) [SERVICE]"
	exit 1
fi

keyDir="/etc/ssl/private"
certDir="/etc/ssl/certs"
mkdir -p "$keyDir"
mkdir -p "$certDir"

key="${keyDir}/${1}-self.key"
cert="${certDir}/${1}-self.crt"

echo "$me Generating key: $key"
echo "$me Generating certificate: $cert"

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "$key" -out "$cert"