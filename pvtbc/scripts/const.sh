# Set an environment variable based on an optional override (TICKEN_NETWORK_{name})
# from the calling shell.  If the override is not available, assign the parameter
# to a default value.
function context() {
  local name=$1
  local default_value=$2
  local override_name=TICKEN_NETWORK_${name}

  export ${name}="${!override_name:-${default_value}}"
}

#----------------------- TICKEN NETWORK --------------------------#
context DOMAIN "localho.st"

context TICKEN_CHANNEL_NAME "ticken-channel"

context GENESIS_ORG_NAME "ticken"
context ORDERER_ORG_NAME "ordorg"

context BASE_CHAINCODE_PATH "../../../ticken-chaincodes"

context TICKEN_TICKET_CHAINCODE_NAME "cc-ticket"
context TICKEN_TICKET_CHAINCODE_PATH "$BASE_CHAINCODE_PATH/ccticket"

context TICKEN_EVENT_CHAINCODE_NAME "cc-event"
context TICKEN_EVENT_CHAINCODE_PATH "$BASE_CHAINCODE_PATH/ccevent"

context ORDERER_ORG_TYPE "orderer"
context PEER_ORG_TYPE    "peer"
#-----------------------------------------------------------------#

#--------------------------- LOGS --------------------------------#
context BASE_LOGS_PATH  "../logs"
context LOG_FILE        "${BASE_LOGS_PATH}/ticken-network.log"
context DEBUG_FILE      "${BASE_LOGS_PATH}/ticken-network-debug.log"
context LOG_ERROR_LINES 2
#-----------------------------------------------------------------#


#-------------------------- K8S PATH -----------------------------#
context K8S_BASE_PATH           "../k8s"
context K8S_CLUSTER_FILES_PATH  "$K8S_BASE_PATH/cluster"
context K8S_CA_FILES_PATH       "$K8S_BASE_PATH/org/ca"
context K8S_NETWORK_JOBS_PATH   "$K8S_BASE_PATH/jobs"
context K8S_NETWORK_CONFIG_PATH "$K8S_BASE_PATH/config"
context K8S_ORG_JOBS_PATH       "$K8S_BASE_PATH/org/jobs"
context K8S_CHAINCODE_PATH      "$K8S_BASE_PATH/org/chaincode"
context K8S_INGRESS_PATH        "$K8S_BASE_PATH/org/ingress"
context K8S_ORG_CONFIG          "$K8S_BASE_PATH/org/config"
context K8S_ORG_NODES_PATH      "$K8S_BASE_PATH/org/nodes"
#-----------------------------------------------------------------#


#--------------------------- CLUSTER -----------------------------#
context CLUSTER_VOLUME_PATH "/tmp/ticken-pv"
context CLUSTER_NAMESPACE   "ticken-pvtbc-network"
context CLUSTER_NAME        "ticken-pvtbc-network"
context NGINX_HTTP_PORT     80
context NGINX_HTTPS_PORT    443
#-----------------------------------------------------------------#


#------------------------- CONTAINERS ----------------------------#
context CONTAINERS_CLI           "docker"
context LOCAL_REGISTRY_NAME      kind-registry
context LOCAL_REGISTRY_INTERFACE 127.0.0.1
context LOCAL_REGISTRY_PORT      5000
context LOCAL_REGITRY_STORAGE    "/tmp/ticken-registry"
#-----------------------------------------------------------------#


#------------------------ FABRIC IMAGES --------------------------#
context FABRIC_VERSION       2.4
context FABRIC_PEER_IMAGE    "hyperledger/fabric-peer:$FABRIC_VERSION"
context FABRIC_TOOLS_IMAGE   "hyperledger/fabric-tools:$FABRIC_VERSION"
context FABRIC_ORDERER_IMAGE "hyperledger/fabric-orderer:$FABRIC_VERSION"

context FABRIC_CA_IMAGE            "hyperledger/fabric-ca:1.5.2"
context FABRIC_CA_TOOLS_IMAGE      "hyperledger/fabric-ca-tools:latest"
context FABRIC_CCAAS_BUILDER_IMAGE "hyperledger/fabric-ccenv:1.4.8"

context COUCHDB_IMAGE               "couchdb:3.2.2"
#-----------------------------------------------------------------#