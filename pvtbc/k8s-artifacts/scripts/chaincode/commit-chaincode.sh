CHANNEL_NAME=$1

GENESIS_ORG_NAME=$2
GENESIS_ORG_NODE=$3

EVENT_ORG_NAME=$4
EVENT_ORG_NODE=$5

CHAINCODE_NAME=$6
ORDERER_ORG_NAME=$7

GENESIS_ORG_TLS_ROOTCERT_FILE=/orgs/peer-orgs/${GENESIS_ORG_NAME}/msp/tlscacerts/tlsca-signcert.pem
EVENT_ORG_TLS_ROOTCERT_FILE=/orgs/peer-orgs/${EVENT_ORG_NAME}/msp/tlscacerts/tlsca-signcert.pem

GENESIS_ORG_PEER=${GENESIS_ORG_NAME}-${GENESIS_ORG_NODE}:7051
EVENT_ORG_PEER=${EVENT_ORG_NAME}-${EVENT_ORG_NODE}:7051

export FABRIC_CFG_PATH=/config
export CORE_PEER_LOCALMSPID="${GENESIS_ORG_NAME}MSP"
export CORE_PEER_ADDRESS=${GENESIS_ORG_NAME}-${GENESIS_ORG_NODE}:7051
export CORE_PEER_MSPCONFIGPATH=/orgs/peer-orgs/${GENESIS_ORG_NAME}/users/${GENESIS_ORG_NAME}-admin/msp
export CORE_PEER_TLS_ROOTCERT_FILE=/orgs/peer-orgs/${GENESIS_ORG_NAME}/msp/tlscacerts/tlsca-signcert.pem

# commit the chaincode
peer lifecycle chaincode commit \
  --channelID     ${CHANNEL_NAME} \
  --name          ${CHAINCODE_NAME} \
  --version       1 \
  --sequence      1 \
  --peerAddresses ${GENESIS_ORG_PEER} --tlsRootCertFiles ${GENESIS_ORG_TLS_ROOTCERT_FILE} \
  --peerAddresses ${EVENT_ORG_PEER}   --tlsRootCertFiles ${EVENT_ORG_TLS_ROOTCERT_FILE} \
  --orderer       ${ORDERER_ORG_NAME}-orderer0:7050 \
  --tls --cafile  /orgs/orderer-orgs/${ORDERER_ORG_NAME}/nodes/${ORDERER_ORG_NAME}-orderer0/tls/signcerts/tls-cert.pem


