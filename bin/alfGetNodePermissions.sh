#!/bin/bash
# set -x
# param section

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh

function __show_command_options() {
  echo "  command options:"
  echo "    -n    NodeRef of the node on which to get the permissions (mandatory)"
  echo 
}

# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfGetNodePermissions.sh gets all defined permissions on a node. It returns a JSON dump with all defined permissions on a node."
  echo
  echo "  usage examples:"
  echo
  echo "  ./alfGetNodePermissions.sh -n workspace://SpacesStore/c6554289-1685-4e9f-a506-012c665803fe" 
  echo "     --> list defined permissions on that node"
  echo
}

ALF_CMD_OPTIONS="${ALF_GLOBAL_OPTIONS}n:"
ALF_PERMISSION_NODE_NODEREF=""

function __process_cmd_option() {
  local OPTNAME=$1
  local OPTARG=$2

  case $OPTNAME
  in
    n)
      ALF_PERMISSION_NODE_NODEREF=$OPTARG;;
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
  echo "The nodeRef is a mandatory parameter"
  exit 1
fi

if __is_noderef $ALF_PERMISSION_NODE_NODEREF
then
  __split_noderef $ALF_PERMISSION_NODE_NODEREF
  __encode_url_param $UUID
  ENC_UUID=$ENCODED_PARAM
  __encode_url_param $STORE
  ENC_STORE=$ENCODED_PARAM
  __encode_url_param $PROTOCOL
  ENC_PROTOCOL=$ENCODED_PARAM

  curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW -H 'Content-Type:application/json' $ALF_EP/service/slingshot/doclib/permissions/$ENC_PROTOCOL/$ENC_STORE/$ENC_UUID
else
  echo "Invalid nodeRef"
  exit 1	
fi


#
#
#http://localhost:8080/alfresco/service/slingshot/doclib/permissions

