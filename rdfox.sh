#!/usr/bin/env bash

if [[ -z "${RDFOX_LICENSE_BASE64}" ]] ; then
  echo "ERROR: Create an environment variable RDFOX_LICENSE_BASE64 that has the base64 encoded content of your RDFox license"
  exit 1
fi

echo "${RDFOX_LICENSE_BASE64}" | base64 -d > /home/rdfox/.RDFox/RDFox.lic
export RDFOX_LICENSE_BASE64=

#
# From here, everything works as normal
#
exec /opt/RDFox/RDFox


