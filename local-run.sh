#!/usr/bin/env bash
_IMAGE_NAME="docker.io/agnosai/rdfox"
_IMAGE_VERSION="latest"

if [[ -z "${RDFOX_LICENSE_BASE64}" ]] ; then
  echo "ERROR: Create an environment variable RDFOX_LICENSE_BASE64 that has the base64 encoded content of your RDFox license"
  exit 1
fi

./local-build.sh || exit $?

# TODO: I need to find out how to leave RDFox running in the background while the rest of the code here continues...& does not work!
docker run --rm -it --env RDFOX_LICENSE_BASE64="${RDFOX_LICENSE_BASE64:-rubbish}" -p 12110:12110 $(< image.id)

# Give it a moment for the container and RDFox to start up
sleep 5

# Create data store
# dstore create LUBM par-complex-nn -persist-df=file -persist-roles=file -init-resource-capacity=1000000 -init-triple-capacity=140000000 auto-update-statistics true
curl -i -X POST --user admin:admin "localhost:12110/datastores/test-repository?type=par-complex-nn"
