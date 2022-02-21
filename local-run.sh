#!/usr/bin/env bash
_IMAGE_NAME="docker.io/agnosai/rdfox"
_IMAGE_VERSION="latest"

if [[ -z "${RDFOX_LICENSE_BASE64}" ]] ; then
  echo "ERROR: Create an environment variable RDFOX_LICENSE_BASE64 that has the base64 encoded content of your RDFox license"
  exit 1
fi

./local-build.sh || exit $?

docker run --rm --interactive --env RDFOX_LICENSE_BASE64="${RDFOX_LICENSE_BASE64:-rubbish}" $(< image.id)