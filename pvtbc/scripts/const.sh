# Set an environment variable based on an optional override (TICKEN_NETWORK_{name})
# from the calling shell.  If the override is not available, assign the parameter
# to a default value.
function context() {
  local name=$1
  local default_value=$2
  local override_name=TICKEN_NETWORK_${name}

  export ${name}="${!override_name:-${default_value}}"
}



readonly TICKEN_EVENT_CHAINCODE_NAME="ticken-event-chaincode"
readonly TICKEN_EVENT_CHAINCODE_PATH="../../../ticken-chaincodes/ticken-event-chaincode"

readonly TICKEN_TICKET_CHAINCODE_NAME="ticken-ticket-chaincode"
readonly TICKEN_TICKET_CHAINCODE_PATH="../../../ticken-chaincodes/ticken-event-chaincode"


#----------------------- TICKEN NETWORK --------------------------#
context TICKEN_CHANNEL_NAME "ticken-channel"
#-----------------------------------------------------------------#


#---------------------- ORGANIZATIONS ----------------------------#
context GENESIS_ORG_NAME "ticken"
context ORDERER_ORG_NAME "orderer"
#-----------------------------------------------------------------#


#-------------------------- K8S PATH -----------------------------#
context K8S_BASE_PATH           "../k8s"
context K8S_CLUSTER_FILES_PATH  "$K8S_BASE_PATH/cluster"
context K8S_CA_FILES_PATH       "$K8S_BASE_PATH/org/ca"
context K8S_NETWORK_JOBS_PATH   "$K8S_BASE_PATH/jobs"
context K8S_ORG_JOBS_PATH       "$K8S_BASE_PATH/org/jobs"
context K8S_ORG_ORD_NODES_PATH  "$K8S_BASE_PATH/org/ord-node"
context K8S_ORG_PEER_NODES_PATH "$K8S_BASE_PATH/org/peer-node"
#-----------------------------------------------------------------#


#--------------------------- CLUSTER -----------------------------#
context CLUSTER_VOLUME_PATH "/tmp/ticken-pv"
context CLUSTER_NAMESPACE   "ticken-pvtbc-network"
context CLUSTER_NAME        "ticken-pvtbc-network"
#-----------------------------------------------------------------#


#------------------------- CONTAINERS ----------------------------#
context CONTAINERS_CLI           "docker"
context LOCAL_REGISTRY_NAME      kind-registry
context LOCAL_REGISTRY_INTERFACE 127.0.0.1
context LOCAL_REGISTRY_PORT      5000
#-----------------------------------------------------------------#


#------------------------ FABRIC IMAGES --------------------------#
context FABRIC_PEER_IMAGE     "hyperledger/fabric-peer:2.3"
context FABRIC_ORDERER_IMAGE  "hyperledger/fabric-orderer:2.3"
context FABRIC_CA_IMAGE       "hyperledger/fabric-ca:1.4.9"
context FABRIC_TOOLS_IMAGE    "hyperledger/fabric-tools:2.3"
context FABRIC_CA_TOOLS_IMAGE "hyperledger/fabric-ca-tools:latest"
context COUCHDB_IMAGE         "couchdb:3.2.2"
#-----------------------------------------------------------------#