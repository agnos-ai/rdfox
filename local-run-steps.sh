#!/usr/bin/env bash

# Create repository
echo "Trying to connect every second until the server is available..."
test=1
while [ ${test} != 0 ]; do
  curl -i -X POST --user admin:admin "localhost:12110/datastores/test-repository?type=par-complex-nn"
  test=$?
  sleep 1
done

# TODO: remaining tasks here...
# dstore create LUBM par-complex-nn -persist-df=file 
# -persist-roles=file -init-resource-capacity=1000000 
# -init-triple-capacity=140000000 auto-update-statistics true
