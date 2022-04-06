#!/usr/bin/env bash

if [[ -z "${RDFOX_LICENSE_BASE64}" ]] ; then
  echo "ERROR: Create an environment variable RDFOX_LICENSE_BASE64 that has the base64 encoded content of your RDFox license"
  exit 1
fi

# Server directory = /home/rdfox/.RDFox
# Lincense Key Location = /opt/RDFox/RDFox.lic
echo "${RDFOX_LICENSE_BASE64}" | base64 -d > /home/rdfox/.RDFox/RDFox.lic

#
# From here, everything works as normal
#
exec /opt/RDFox/RDFox -server-directory /home/rdfox/.RDFox -license-file /home/rdfox/.RDFox/RDFox.lic -role admin -password admin shell . "set endpoint.port 12110" "endpoint start" | tee /home/rdfox/rdfox.log

# curl -i -X POST "localhost:12110/datastores/family?type=par-complex-nn"
