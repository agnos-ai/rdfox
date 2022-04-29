# rdfox

RDFox image that accepts an RDFox license injected via an environment
variable.

This Docker container, before starting RDFox, checks for the existence
of an environment variable called `RDFOX_LICENSE_BASE64` which is
assumed to contain the base64-encoded version of your RDFox license.


Once you received a RDFox.lic license file from RDFox, the variable above can be created as per below.

`export RDFOX_LICENSE_BASE64=$(base64 <path>/RDFox.lic)`


Running the container

`./local-run.sh -u "admin" -p "admin" -n "LUBM" `


Cleaning up the local environment

`./local-cleanup.sh`


Accessing the image shell

`docker exec -it <imageID> /bin/sh`


<!-- TODO:
I want to save the encoded license and repository user and password somewhere, like a yaml file example below. 

RDFox:
    image:
        password: ENC[AES256_GCM,data:WXCNOcr,iv:9p7+1Ese5O,tag:huhPirzrA,type:str]
        RDFOX_LICENSE_BASE64: inKydjTu5xwyl96iRYk1j87ZcadQWE/
    admin:
        password: ENC[AES256_GCM,data:YTgGzXY=,iv:A3mKF4LN,tag:KrhF/JkwLp,type:str]` -->