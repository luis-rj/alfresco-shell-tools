#!/bin/bash
# set -x
# param section

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh



function __show_command_options() {
  echo "  command options:"
  echo "    -s    Site name"
  echo "    -n    Site space name"
  echo "    -t    Site space title"
  echo "    -d    Site space description"
  echo "    -T    Site space type (default cm:folder)"
  echo "    -p    path relative to documentlibrary"
  echo 
}


# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfCreateSiteSpace.sh creates a new space inside a given Site"
  echo
  echo "  usage examples:"
  echo
  echo "  ./alfCreateSiteSpace.sh -s somesite -n folderA -t \"New folder title\" -d \"New folder description\" -T cm:folder -p A/B/C"
  echo "     --> creates a new space in a Site with somesite shortname (must exist) in the A/B/C path (must exist)"
  echo
}

ALF_CMD_OPTIONS="${ALF_GLOBAL_OPTIONS}s:n:t:d:T:p:"
ALF_SITE_NAME=""
ALF_SITE_SPACE_NAME=""
ALF_SITE_SPACE_TITLE=""
ALF_SITE_SPACE_DESCRIPTION=""
ALF_SITE_SPACE_TYPE=""
ALF_SITE_SPACE_PATH=""

function __process_cmd_option() {
  local OPTNAME=$1
  local OPTARG=$2

  case $OPTNAME
  in
    s)
      ALF_SITE_NAME=$OPTARG;;
    n)
      ALF_SITE_SPACE_NAME=$OPTARG;;
    t)
      ALF_SITE_SPACE_TITLE=$OPTARG;;
    d)
      ALF_SITE_SPACE_DESCRIPTION=$OPTARG;;
    T)
      ALF_SITE_SPACE_TYPE=$OPTARG;;
    p)
      ALF_SITE_SPACE_PATH=$OPTARG;;
  esac
}

__process_options "$@"

# shift away parsed args
shift $((OPTIND-1))

if $ALF_VERBOSE
then
  ALF_CURL_OPTS="$ALF_CURL_OPTS -v"
  echo "connection params:"
  echo "  user: $ALF_UID"
  echo "  endpoint: $ALF_EP"
  echo "  curl opts: $ALF_CURL_OPTS"
fi

if [[ "$ALF_SITE_NAME" == "" ]]
then
  echo "an Alfresco Site shortname is required"
  exit 1
fi

if [[ "$ALF_SITE_SPACE_NAME" == "" ]]
then
  echo "a name for the new space is required"
  exit 1
fi

ENC_ALF_SITE_SPACE_PATH=""
if [[ "$ALF_SITE_SPACE_PATH" != "" ]]
then
	__encode_url_path $ALF_SITE_SPACE_PATH
	ENC_ALF_SITE_SPACE_PATH=$ENCODED_PATH
fi

ALF_JSON=$(echo '{}' | $ALF_JSHON -s "$ALF_SITE_SPACE_NAME" -i name -s "$ALF_SITE_SPACE_TITLE" -i title -s "$ALF_SITE_SPACE_DESCRIPTION" -i description)

#echo $ALF_JSON

echo $ALF_JSON | curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW -H 'Content-Type:application/json' -d@- -X POST $ALF_EP/service/api/site/folder/$ALF_SITE_NAME/documentlibrary/$ALF_SITE_SPACE_PATH


# {
#     "nodeRef": "workspace://SpacesStore/e70eb2ef-b129-4696-967b-7409dc9ffef4"
#        ,
#        "site": "swsdp",
#        "container": "documentlibrary",
# }
#
#http://localhost:8080/alfresco/service/api/site/folder

