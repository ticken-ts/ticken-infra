ORG_NAME="ticken"
NODE_NUM=0
ORG_NODE="peer$NODE_NUM"
CLUSTER_VOLUME_PATH="/tmp/ticken-pv"

CC_NAME="cc-event"
CHANNEL_NAME="ticken-channel"
ORDERER_ENDPOINT="grpcs://ticken.chain.net/orderer/nodes/0"

export FABRIC_CFG_PATH=${CLUSTER_VOLUME_PATH}/org-config
export CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"
export CORE_PEER_ADDRESS="grpcs://ticken.chain.net/${ORG_NAME}/nodes/${NODE_NUM}"
export CORE_PEER_MSPCONFIGPATH="${CLUSTER_VOLUME_PATH}/orgs/peer-orgs/${ORG_NAME}/users/Admin@${ORG_NAME}/msp"
export CORE_PEER_TLS_ROOTCERT_FILE="${CLUSTER_VOLUME_PATH}/orgs/peer-orgs/${ORG_NAME}/nodes/${ORG_NODE}.${ORG_NAME}/tls/ca.crt"

COMMAND='{"function":"Create","Args":["event-id-2", "event-name-2", "2022-12-12T15:04:05Z"]}'

/Users/facundotorraca/Documents/ticken/ticken-dev/test-pvtbc/test-network-k8s/bin/peer chaincode invoke \
  -n              $CC_NAME \
  -C              $CHANNEL_NAME \
  -c              $COMMAND \
  --orderer       $ORDERER_ENDPOINT \
  --tls --cafile  $CLUSTER_VOLUME_PATH/orgs/ord-orgs/orderer/nodes/ord0.orderer/tls/signcerts/cert.pem
