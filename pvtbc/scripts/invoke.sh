NODE_NUM=0
ORG_NAME=$1
ORG_NODE="peer$NODE_NUM"
CLUSTER_VOLUME_PATH="/tmp/ticken-pv"

CC_NAME="cc-event"
CHANNEL_NAME="ticken-org1-channel"
ORDERER_ENDPOINT="ordorg-orderer0.localho.st:443"
ORDERER_CAFILE="${CLUSTER_VOLUME_PATH}/orgs/orderer-orgs/ordorg/nodes/ordorg-orderer0/tls/signcerts/tls-cert.pem"

export FABRIC_CFG_PATH=../k8s/org/config/peer

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID=${ORG_NAME}MSP
export CORE_PEER_ADDRESS="${ORG_NAME}-${ORG_NODE}.localho.st:443"
export CORE_PEER_MSPCONFIGPATH=${CLUSTER_VOLUME_PATH}/orgs/peer-orgs/${ORG_NAME}/users/${ORG_NAME}-admin/msp
export CORE_PEER_TLS_ROOTCERT_FILE=${CLUSTER_VOLUME_PATH}/orgs/peer-orgs/${ORG_NAME}/msp/tlscacerts/tlsca-signcert.pem


COMMAND='{"Function":"Create","Args":["f2d4e101-cad8-4322-be15-3eb1daac9a92", "event-name-1", "2022-12-12T15:04:05Z"]}'
#COMMAND='{"Function":"Get","Args":["0242ebb2-e9ad-433f-8dd6-d6c213e6079d"]}'

#../bin/peer chaincode invoke \
#  --name         $CC_NAME \
#  --channelID    $CHANNEL_NAME \
#  --ctor         "${COMMAND}" \
#  --orderer      $ORDERER_ENDPOINT \
#  --tls --cafile $ORDERER_CAFILE

#../bin/peer channel list \
# --orderer $ORDERER_ENDPOINT \
# --tls --cafile ORDERER_CAFILE

#../bin/peer lifecycle chaincode queryinstalled \
#  --orderer $ORDERER_ENDPOINT \
#  --tls --cafile ORDERER_CAFILE

#../bin/peer lifecycle chaincode checkcommitreadiness \
#  -n "cc-event" --version 1 --sequence 1 \
#  --channelID ticken-org1-channel \
#  --orderer $ORDERER_ENDPOINT \
#  --tls --cafile ORDERER_CAFILE

#/Users/facundotorraca/Documents/ticken/ticken-dev/test-pvtbc/test-network-k8s/bin/peer channel fetch config config_block.pb \
#  --orderer $ORDERER_ENDPOINT \
#  --channelID $CHANNEL_NAME \
#  --tls \
#  --cafile $ORDERER_CAFILE
