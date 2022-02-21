# rdfox

RDFox image that accepts an RDFox license injected via an environment
variable.

This Docker container, before starting RDFox, checks for the existence
of an environment variable called `RDFOX_LICENSE_BASE64` which is
assumed to contain the base64-encoded version of your RDFox license.



