NODE_NUM=0
ORG_NAME="ticken"
ORG_NODE="peer$NODE_NUM"
CLUSTER_VOLUME_PATH="/tmp/ticken-pv"

CC_NAME="cc-event"
CHANNEL_NAME="ticken-channel"
ORDERER_ENDPOINT="ordorg-orderer0.localho.st:443"
ORDERER_CAFILE="${CLUSTER_VOLUME_PATH}/orgs/orderer-orgs/ordorg/nodes/ordorg-orderer0/tls/signcerts/tls-cert.pem"

export FABRIC_CFG_PATH=../k8s/org/config/peer

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID=tickenMSP
export CORE_PEER_ADDRESS="${ORG_NAME}-${ORG_NODE}.localho.st:443"
export CORE_PEER_MSPCONFIGPATH=${CLUSTER_VOLUME_PATH}/orgs/peer-orgs/${ORG_NAME}/users/${ORG_NAME}-admin/msp
export CORE_PEER_TLS_ROOTCERT_FILE=${CLUSTER_VOLUME_PATH}/orgs/peer-orgs/ticken/msp/tlscacerts/tlsca-signcert.pem


COMMAND='{"Function":"Create","Args":["event-id-2", "event-name-2", "2022-12-12T15:04:05Z"]}'

../bin/peer chaincode invoke \
  --name         $CC_NAME \
  --channelID    $CHANNEL_NAME \
  --ctor         "${COMMAND}" \
  --orderer      $ORDERER_ENDPOINT \
  --tls --cafile $ORDERER_CAFILE


#../bin/peer channel list \
#  --orderer $ORDERER_ENDPOINT \
#  --tls --cafile ORDERER_CAFILE
