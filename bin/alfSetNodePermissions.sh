#!/bin/bash
# set -x
# param section

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh

function __show_command_options() {
  echo "  command options:"
  echo "    -n    NodeRef of the node on which to set the permissions (mandatory)"
  echo "    -a    Authority the define the permission (mandatory)"
  echo "    -r    Role to define the permission (mandatory)"
  echo "    -i    Permissions inheritance definition on node (default true)"
  echo 
}

# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfSetNodePermissions.sh defines permissions on a node. It returns a JSON dump of the newly defined permissions."
  echo
  echo "  usage examples:"
  echo
  echo "  ./alfSetNodePermissions.sh -n workspace://SpacesStore/c6554289-1685-4e9f-a506-012c665803fe -a abeecher -r Consumer -i false" 
  echo "     --> defines a specific permissions on a node"
  echo
}

ALF_CMD_OPTIONS="${ALF_GLOBAL_OPTIONS}n:a:r:i:"
ALF_PERMISSION_NODE_NODEREF=""
ALF_PERMISSION_AUTHORITY=""
ALF_PERMISSION_ROLE=""
ALF_PERMISSION_INHERITANCE=true

function __process_cmd_option() {
  local OPTNAME=$1
  local OPTARG=$2

  case $OPTNAME
  in
    n)
      ALF_PERMISSION_NODE_NODEREF=$OPTARG;;
    a)
      ALF_PERMISSION_AUTHORITY=$OPTARG;;
    r)
      ALF_PERMISSION_ROLE=$OPTARG;;
    i)
      ALF_PERMISSION_INHERITANCE=$OPTARG;;
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

if [[ "$ALF_PERMISSION_NODE_NODEREF" == "" ]]
then
  echo "The nodeRef is a mandatory parameter to define the permission"
  exit 1
fi

if [[ "$ALF_PERMISSION_AUTHORITY" == "" ]]
then
  echo "Authority is a mandatory parameter to define the permission"
  exit 1
fi

if [[ "$ALF_PERMISSION_ROLE" == "" ]]
then
  echo "Role is a mandatory parameter to define the permission"
  exit 1
fi

ALF_JSON=$(echo '{}' | $ALF_JSHON -n array -n object -s "$ALF_PERMISSION_AUTHORITY" -i authority -s "$ALF_PERMISSION_ROLE" -i role -i append -i permissions -n $ALF_PERMISSION_INHERITANCE -i isInherited)

echo $ALF_JSON

if __is_noderef $ALF_PERMISSION_NODE_NODEREF
then
  __split_noderef $ALF_PERMISSION_NODE_NODEREF
  __encode_url_param $UUID
  ENC_UUID=$ENCODED_PARAM
  __encode_url_param $STORE
  ENC_STORE=$ENCODED_PARAM
  __encode_url_param $PROTOCOL
  ENC_PROTOCOL=$ENCODED_PARAM

  echo $ALF_JSON | curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW -H 'Content-Type:application/json' -d@- -X POST $ALF_EP/service/slingshot/doclib/permissions/$ENC_PROTOCOL/$ENC_STORE/$ENC_UUID
else
  echo "Invalid nodeRef"
  exit 1	
fi


#
#
#http://localhost:8080/alfresco/service/slingshot/doclib/permissions

