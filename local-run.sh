#!/usr/bin/env bash
_IMAGE_NAME="docker.io/agnosai/rdfox"
_IMAGE_VERSION="latest"

if [[ -z "${RDFOX_LICENSE_BASE64}" ]] ; then
  echo "ERROR: Create an environment variable RDFOX_LICENSE_BASE64 that has the base64 encoded content of your RDFox license"
  exit 1
fi

./local-build.sh || exit $?

# Run RDFox tasks in the background
./local-run-steps.sh&

# RDFox won't run in the background and needs to be left running here in its console mode.
docker run --rm -it --env RDFOX_LICENSE_BASE64="${RDFOX_LICENSE_BASE64:-rubbish}" -p 12110:12110 $(< image.id)

