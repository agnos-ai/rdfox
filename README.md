# rdfox

RDFox image that accepts an RDFox license injected via an environment
variable.

This Docker container, before starting RDFox, checks for the existence
of an environment variable called `RDFOX_LICENSE_BASE64` which is
assumed to contain the base64-encoded version of your RDFox license.


Once you received a RDFox.lic license file from RDFox, the variable above can be created as per below.

`export RDFOX_LICENSE_BASE64=$(base64 <path>/RDFox.lic)`


Running the container

`./local-run.sh`


Cleaning up the local environment

`./local-cleanup.sh`


Accessing the image shell

`docker exec -it <imageID> /bin/sh`