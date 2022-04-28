#!/usr/bin/env bash

source ./terminal.sh
customize_terminal_output

help()
{
   # Display Help
   echo 
   echo   "Usage:"
   echo   "   ./local-run.sh [OPTIONS]"
   echo   "   Starts an RDFox container with an injected license."
   echo 
   echo   "Options:"
   echo   "   -u  User."
   echo   "   -p  Password."
   echo   "   -r  HTTP port number."
   echo   "   -n  Repository name."
   echo   "   -t  Repository type. Refer to the RDFox documentation for the types available."
   echo
}


echo "${header}Set and validate input parameters${reset}"

while getopts ":u:p:r:n:t:h:" opt; do
  case $opt in
    u) user="$OPTARG"
    ;;
    p) password="$OPTARG"
    ;;
    r) port="$OPTARG"
    ;;
    n) repositoryname="$OPTARG"
    ;;
    t) repositorytype="$OPTARG"
    ;;
    h) help
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    exit 1
    ;;
  esac

  case $OPTARG in
    -*) echo "Option $opt needs a valid argument"
    exit 1
    ;;
  esac
done


if [[ -z "${user}" ]] ; then
  echo "${error}ERROR${reset}: User is a mandatory paramenter."
  help
  exit 1
fi

if [[ -z "${password}" ]] ; then
  echo "${error}ERROR${reset}: Password is a mandatory paramenter."
  help
  exit 1
fi

if [[ -z "${port}" ]] ; then
  echo "${error}ERROR${reset}: Port is a mandatory paramenter."
  help
  exit 1
fi

if [[ -z "${repositoryname}" ]] ; then
  echo "${error}ERROR${reset}: Repository name is a mandatory paramenter."
  help
  exit 1
fi

if [[ -z "${repositorytype}" ]] ; then
  echo "${error}ERROR${reset}: Repository type is a mandatory paramenter."
  help
  exit 1
fi

if [[ -z "${RDFOX_LICENSE_BASE64}" ]] ; then
  echo "ERROR: Create an environment variable RDFOX_LICENSE_BASE64 that has the base64 encoded content of your RDFox license"
  help()
  exit 1
fi


echo "${header}Build Image${reset}"
./local-build.sh || exit $?


echo "${header}Run Container, Start RDFox Server and Create Repository${reset}"
{ 
  # cap-drop ALL: oxfordsemantic/rdfox repositoryname have been designed to run with no superuser capabilities
  docker run --rm --cap-drop ALL --name rdfoxcontainer \
  --env RDFOX_LICENSE_BASE64=${RDFOX_LICENSE_BASE64} \
  --env RDFOX_USER=${user} \
  --env RDFOX_PASSWORD=${password} \
  --env RDFOX_PORT=${port} \
  --env RDFOX_REPOSITORYNAME=${repositoryname} \
  --env RDFOX_REPOSITORYTYPE=${repositorytype} \
  -v $(pwd)/data:/home/rdfox/data -v $(pwd)/ontology:/home/rdfox/ontology \
  -p 12110:12110 $(< image.id)
}& # Start the RDFox Container in the background


test=1
while [ ${test} != 0 ]; do
  # It will try to connect to the server every second until the server is available. Failed attempts to connect will not throw errors.
  curl -i -X POST --user "${user}":"${password}" "localhost:${port}/datastores/${repositoryname}?type=${repositorytype}" 2>/dev/null
  test="${?}"
  sleep 0.5
done


echo "${header}List Repositories${reset}"
curl -i -X GET --user "${user}":"${password}" "localhost:${port}/datastores"


echo "${header}Download Test Datasets${reset}"
# Download the test dataset from gcloud
# TODO: Automate authentication, which is currently done via browser login.
gsutil -o GSUtil:parallel_process_count=1 rsync -r gs://lubm-benchmark ./data


echo "${header}Import Ontology${reset}"
curl -i -X POST --user "${user}":"${password}" "localhost:${port}/datastores/${repositoryname}/content" -H "Content-Type:" -T home/rdfox/ontology/univ-bench.ttl


echo "${header}Import Data${reset}"
curl -i -X POST --user "${user}":"${password}" "localhost:${port}/datastores/${repositoryname}/content" -H "Content-Type:" -T home/rdfox/data/lubm-1000-universities.nt.gz


# TODO: remaining tasks here...
# dstore create LUBM par-complex-nn -persist-df=file 
# -persist-roles=file -init-resource-capacity=1000000 
# -init-triple-capacity=140000000 auto-update-statistics true



