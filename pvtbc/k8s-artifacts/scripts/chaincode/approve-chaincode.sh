CHANNEL_NAME=$1
ORG_NAME=$2
ORG_NODE=$3
CHAINCODE_ID=$4
CHAINCODE_NAME=$5
ORDERER_ORG_NAME=$6

export FABRIC_CFG_PATH=/config
export CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"
export CORE_PEER_ADDRESS=${ORG_NAME}-${ORG_NODE}:7051
export CORE_PEER_MSPCONFIGPATH=/orgs/peer-orgs/${ORG_NAME}/users/${ORG_NAME}-admin/msp
export CORE_PEER_TLS_ROOTCERT_FILE=/orgs/peer-orgs/${ORG_NAME}/msp/tlscacerts/tlsca-signcert.pem

peer lifecycle chaincode approveformyorg \
  --channelID     ${CHANNEL_NAME} \
  --name          ${CHAINCODE_NAME} \
  --package-id    ${CHAINCODE_ID} \
  --version       1 \
  --sequence      1 \
  --orderer       ${ORDERER_ORG_NAME}-orderer0:7050 \
  --tls --cafile   /orgs/orderer-orgs/${ORDERER_ORG_NAME}/nodes/${ORDERER_ORG_NAME}-orderer0/tls/signcerts/tls-cert.pem
