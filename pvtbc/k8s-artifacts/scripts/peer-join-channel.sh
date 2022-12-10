CHANNEL_NAME=$1
JOINING_ORG_NODE=$2
JOINING_ORG_NAME=$3
ORDERER_ORG_NAME=$4

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="${JOINING_ORG_NAME}MSP"
export CORE_PEER_ADDRESS=${JOINING_ORG_NAME}-${JOINING_ORG_NODE}:7051
export CORE_PEER_MSPCONFIGPATH=/orgs/peer-orgs/${JOINING_ORG_NAME}/users/Admin@${JOINING_ORG_NAME}/msp
export CORE_PEER_TLS_ROOTCERT_FILE=/orgs/peer-orgs/${JOINING_ORG_NAME}/nodes/${JOINING_ORG_NODE}.${JOINING_ORG_NAME}/tls/ca.crt

peer channel join \
  --blockpath   /channel-artifacts/${CHANNEL_NAME}_genesis_block.pb \
  --orderer     ${ORDERER_ORG_NAME} \
  --tls         \
  --cafile      /orgs/ord-orgs/${ORDERER_ORG_NAME}/nodes/ord0.${ORDERER_ORG_NAME}/tls/signcerts/cert.pem