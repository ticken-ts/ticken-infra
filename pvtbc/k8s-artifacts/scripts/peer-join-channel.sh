#export FABRIC_CFG_PATH=${PWD}configtx

export CHANNEL_NAME=$1

export ORG_NAME=$2
export ORG_DOMAIN=$3

export ORDERER_ORG_NAME=$4
export ORDERER_ORG_DOMAIN=$5

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"
export CORE_PEER_ADDRESS=${ORG_NAME}-peer0:7051
export CORE_PEER_MSPCONFIGPATH=/orgs/peer-orgs/${ORG_NAME}/users/Admin@${ORG_DOMAIN}/msp

export $CORE_PEER_TLS_ROOTCERT_FILE=/orgs/peer-orgs/${ORG_NAME}/msp/tlscacerts/ca-${ORG_NAME}-7054-ca-${ORG_NAME}.pem

echo "MSP: ${CORE_PEER_LOCALMSPID}"
echo "Config: ${CORE_PEER_MSPCONFIGPATH}"
echo "TLS Root CA: ${CORE_PEER_TLS_ROOTCERT_FILE}"

peer channel join \
  --blockpath   /channel-artifacts/${CHANNEL_NAME}_genesis_block.pb \
  --orderer     ${ORDERER_ORG_NAME} \
  --tls         \
  --cafile      /orgs/ord-orgs/${ORDERER_ORG_NAME}/nodes/ord0.${ORDERER_ORG_DOMAIN}/tls/signcerts/cert.pem