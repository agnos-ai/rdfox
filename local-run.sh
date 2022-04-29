#!/usr/bin/env bash

source ./terminal.sh
customize_terminal_output

help()
{
   # Display Help
   echo 
   echo "${header}******************** Usage and Options ********************${reset}"
   echo   "Usage:"
   echo   "   ./local-run.sh [OPTIONS]"
   echo   "   Starts an RDFox container with an injected license."
   echo 
   echo   "Options:"
   echo   "   -u  User."
   echo   "   -p  Password."
   echo   "   -r  HTTP port number."
   echo   "   -n  Repository name. "
   echo   "   -t  Repository type: par-simple-nn, par-simple-nw, par-simple-ww, par-complex-nn, par-complex-nw, par-complex-ww. Refer to the RDFox documentation for more details."
   echo   "   -h  Help."
   echo
   exit 0
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
    *) 
      echo "${error}ERROR${reset}: Invalid parameter."
      help
    ;;
    u|p|r|n|t|h)
    ;;
  esac

  case $OPTARG in
    -*) echo "Option $opt needs a valid argument"
    exit 1
    ;;
  esac
done

if [[ -z "${repositorytype}" ]] ; then
       repositorytype="par-complex-nn"
fi

if [[ -z "${port}" ]] ; then
       port="12110"
fi

if [[ -z "${user}" ]] || [[ -z "${password}" ]] || [[ -z "${repositoryname}" ]] ; then
  echo "${error}ERROR${reset}: A mandatory paramenter is missing."
  help
fi

echo "user: "$user
echo "password: "$password
echo "port: "$port
echo "repositoryname: "$repositoryname
echo "repositorytype: "$repositorytype
echo "Parameter validation complete. "

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
  curl -X POST --user "${user}":"${password}" "localhost:${port}/datastores/${repositoryname}?type=${repositorytype}" 2>/dev/null
  test="${?}"
  sleep 0.5
done


# Include the Northwind Sample Data Store for Demos
echo "${header}Set up Nothwind sample data store${reset}"
curl -X POST --user "${user}":"${password}" "localhost:${port}/datastores/Northwind?type=par-complex-nn"
curl -X POST --user "${user}":"${password}" "localhost:${port}/datastores/Northwind/content" -H "Content-Type:" -T "data/dumpdataNTRIPLE7.nt"


echo "${header}List Repositories${reset}"
curl -X GET --user "${user}":"${password}" "localhost:${port}/datastores"


echo "${header}Download LUBM Test Datasets${reset}"
# Download the test dataset from gcloud
# TODO: Automate authentication, which is currently done via browser login.
gsutil -o GSUtil:parallel_process_count=1 rsync -r gs://lubm-benchmark ./data


# Grant full access to all downloaded data files and ontologies
chmod -R u+rwx data
chmod -R u+rwx ontology
# ls -al data
# ls -al ontology


echo "${header}Import Data${reset}"
curl -X POST -G \
--data-urlencode "default-graph-name=http://swat.cse.lehigh.edu/onto/univ-bench.owl#data" \
--user "${user}":"${password}" "localhost:${port}/datastores/${repositoryname}/content" \
-H "Content-Type:" -T "data/lubm-10-universities.nt"


echo "${header}Import LUBM Ontology${reset}"
curl -X POST -G \
--data-urlencode "default-graph-name=http://swat.cse.lehigh.edu/onto/univ-bench.owl#ontology" \
--user "${user}":"${password}" -H "Content-Type:text/turtle" -T "ontology/univ-bench.ttl" \
"localhost:${port}/datastores/${repositoryname}/content" 

 
echo "${header}Import LUBM Rules${reset}"
curl -X POST -G \
--data-urlencode "default-graph-name=http://swat.cse.lehigh.edu/onto/univ-bench.owl#rules" \
--user "${user}":"${password}" -H "Content-Type:" -T "rules/rule2.dlog" \
"localhost:${port}/datastores/${repositoryname}/content" 

curl -X POST -G \
--data-urlencode "default-graph-name=http://swat.cse.lehigh.edu/onto/univ-bench.owl#rules" \
--user "${user}":"${password}" -H "Content-Type:" -T "rules/rule9.dlog" \
"localhost:${port}/datastores/${repositoryname}/content" 


# TODO: remaining tasks here...
# dstore create LUBM par-complex-nn -persist-df=file 
# -persist-roles=file -init-resource-capacity=1000000 
# -init-triple-capacity=140000000 auto-update-statistics true




