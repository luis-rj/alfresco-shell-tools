#!/bin/bash
# set -x
# param section

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh

function __show_command_options() {
  echo "  command options:"
  echo "    -n    nodeRef of the folder to create the rule upon"
  echo "    -t    Title of the new rule (mandatory)"
  echo "    -d    Description of the new rule (optional)"
  echo "    -D    Disabled or not (default false)"
  echo "    -r    Apply to children (default true)"
  echo "    -A    Execute Asynchronously (default false)"
  echo "    -c    ConditionDefinitionName (default \"is-subtype\")"
  echo "    -p    ConditionDefinition parameterValue (default cm:content\")"
  echo "    -a    ActionDefinitionName (default \"specialise-type\")"
  echo "    -s    ActionDefinition parameterValue (mandatory)"
  echo "    -T    Rule Type (default \"inbound\")"
  echo 
}

# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfCreateSpaceRule.sh creates a rule on an Alfresco space. It returns a JSON dump of the newly created rule"
  echo
  echo "  usage examples:"
  echo
  echo "  ./alfCreateSpaceRule.sh -n workspace://SpacesStore/c6554289-1685-4e9f-a506-012c665803fe -t "rule\'s title" -d "description of the new rule" -D false -r true -A false -c is-subtype -p cm:folder -a specialise-type -s cm:folder" 
  echo "     --> creates a new rule on the given space"
  echo
}

ALF_CMD_OPTIONS="${ALF_GLOBAL_OPTIONS}n:t:d:D:r:A:c:p:a:s:T:"
ALF_SPACE_NODEREF=""
ALF_SPACE_RULE_TITLE=""
ALF_SPACE_RULE_DESCRIPTION=""
ALF_SPACE_RULE_DISABLED=false
ALF_SPACE_RULE_APPLY_TO_CHILDREN=true
ALF_SPACE_RULE_EXECUTE_ASYNCHRONOUSLY=false
ALF_SAPCE_RULE_CONDITION_DEFINITION_NAME=""
ALF_SPACE_RULE_CONDITION_DEFINITION_IS_SUBTYPE_PARAM=""
ALF_SPACE_RULE_CONDITION_DEFINITION_PARAM_VALUE=""
ALF_SPACE_RULE_ACTION_DEFINITION_NAME=""
ALF_SPACE_RULE_ACTION_DEFINITION_SPECIALISE_TYPE_PARAM=""
ALF_SPACE_RULE_ACTION_DEFINITION_PARAM_VALUE=""
ALF_SPACE_RULE_TYPE=""

function __process_cmd_option() {
  local OPTNAME=$1
  local OPTARG=$2

  case $OPTNAME
  in
    n)
      ALF_SPACE_NODEREF=$OPTARG;;
    t)
      ALF_SPACE_RULE_TITLE=$OPTARG;;
    d)
      ALF_SPACE_RULE_DESCRIPTION=$OPTARG;;
    D)
      ALF_SPACE_RULE_DISABLED=$OPTARG;;
    r)
      ALF_SPACE_RULE_APPLY_TO_CHILDREN=$OPTARG;;
    A)
      ALF_SPACE_RULE_EXECUTE_ASYNCHRONOUSLY=$OPTARG;;
    c)
      ALF_SAPCE_RULE_CONDITION_DEFINITION_NAME=$OPTARG;;
      #ALF_CONDITIONS=("${ALF_CONDITIONS[@]}" $OPTARG);;
    p)
      ALF_SPACE_RULE_CONDITION_DEFINITION_PARAM_VALUE=$OPTARG;;
    a)
      ALF_SPACE_RULE_ACTION_DEFINITION_NAME=$OPTARG;;
    s)
      ALF_SPACE_RULE_ACTION_DEFINITION_PARAM_VALUE=$OPTARG;;
    T)
      ALF_SPACE_RULE_TYPE=$OPTARG;;
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

if [[ "$ALF_SPACE_NODEREF" == "" ]]
then
  echo "The nodeRef of the space to create the rule upon is required"
  exit 1
fi

if [[ "$ALF_SPACE_RULE_TITLE" == "" ]]
then
  echo "A title for the new rule is required"
  exit 1
fi

if [[ "$ALF_SAPCE_RULE_CONDITION_DEFINITION_NAME" == "" ]]
then
	ALF_SAPCE_RULE_CONDITION_DEFINITION_NAME="is-subtype"
fi

if [[ "$ALF_SPACE_RULE_CONDITION_DEFINITION_PARAM_VALUE" == "" ]]
then
	ALF_SPACE_RULE_CONDITION_DEFINITION_PARAM_VALUE="cm:content"
fi

if [[ "$ALF_SPACE_RULE_ACTION_DEFINITION_NAME" == "" ]]
then
	ALF_SPACE_RULE_ACTION_DEFINITION_NAME="specialise-type"
fi

if [[ "$ALF_SPACE_RULE_ACTION_DEFINITION_PARAM_VALUE" == "" ]]
then
  echo "ActionDefinition param value is required"
  exit 1
fi

if [[ "$ALF_SPACE_RULE_TYPE" == "" ]]
then
	ALF_SPACE_RULE_TYPE="inbound"
fi

if [[ "$ALF_SAPCE_RULE_CONDITION_DEFINITION_NAME" == "is-subtype" ]]
then
	ALF_SPACE_RULE_CONDITION_DEFINITION_IS_SUBTYPE_PARAM="type"
fi

if [[ "$ALF_SPACE_RULE_ACTION_DEFINITION_NAME" == "specialise-type" ]]
then
	ALF_SPACE_RULE_ACTION_DEFINITION_SPECIALISE_TYPE_PARAM="type-name"
fi



ALF_JSON=$(echo '{"id": "", "action":{ "conditions": [], "actions": []}, "ruleType":[]}' | $ALF_JSHON -s "$ALF_SPACE_RULE_TITLE" -i title -s "$ALF_SPACE_RULE_DESCRIPTION" -i description -n $ALF_SPACE_RULE_DISABLED -i disabled -n $ALF_SPACE_RULE_APPLY_TO_CHILDREN -i applyToChildren -n $ALF_SPACE_RULE_EXECUTE_ASYNCHRONOUSLY -i executeAsynchronously)

ALF_JSON=$(echo $ALF_JSON | $ALF_JSHON -e action -s "composite-action" -i actionDefinitionName -p)
ALF_JSON=$(echo $ALF_JSON | $ALF_JSHON -e action -e conditions -n object -s "$ALF_SAPCE_RULE_CONDITION_DEFINITION_NAME" -i conditionDefinitionName -n object -s "$ALF_SPACE_RULE_CONDITION_DEFINITION_PARAM_VALUE" -i "$ALF_SPACE_RULE_CONDITION_DEFINITION_IS_SUBTYPE_PARAM" -i parameterValues -i append -i conditions -p)
ALF_JSON=$(echo $ALF_JSON | $ALF_JSHON -e action -e actions -n object -s "$ALF_SPACE_RULE_ACTION_DEFINITION_NAME" -i actionDefinitionName -n object -s "$ALF_SPACE_RULE_ACTION_DEFINITION_PARAM_VALUE" -i "$ALF_SPACE_RULE_ACTION_DEFINITION_SPECIALISE_TYPE_PARAM" -i parameterValues -i append -i actions -p)
ALF_JSON=$(echo $ALF_JSON | $ALF_JSHON -e ruleType -s "$ALF_SPACE_RULE_TYPE" -i append -p)

echo $ALF_JSON

if __is_noderef $ALF_SPACE_NODEREF
then
  __split_noderef $ALF_SPACE_NODEREF
  __encode_url_param $UUID
  ENC_UUID=$ENCODED_PARAM
  __encode_url_param $STORE
  ENC_STORE=$ENCODED_PARAM
  __encode_url_param $PROTOCOL
  ENC_PROTOCOL=$ENCODED_PARAM

  echo $ALF_JSON | curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW -H 'Content-Type:application/json' -d@- -X POST $ALF_EP/service/api/node/$ENC_PROTOCOL/$ENC_STORE/$ENC_UUID/ruleset/rules
else
  echo "Invalid nodeRef"
  exit 1	
fi



# {
#	"data" :
#	{
#		"id" : "a25e412e-31da-4d6b-9890-45eeb7b45935",
#    		"title" : "new rule",
#    		"description" : "",
#    		"ruleType" : ["inbound"],    
#    		"disabled" : false,
#    		"url" : "\/api\/node\/workspace\/SpacesStore\/8281fa82-ba4e-44e7-b503-b75818cc7dfb\/ruleset\/rules\/a25e412e-31da-4d6b-9890-45eeb7b45935"
#	}
# }
#
#http://localhost:8080/alfresco/service/api/node/<nodeRef>/ruleset/rules

