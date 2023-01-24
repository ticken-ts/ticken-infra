ORG_NAME=$1
ORG_NODE=$2
CHAINCODE_NAME=$3

CHAINCODE_PACKAGE_PATH="/chaincodes/${ORG_NAME}/${CHAINCODE_NAME}.tgz"

export FABRIC_CFG_PATH=/config
export CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"
export CORE_PEER_ADDRESS=${ORG_NAME}-${ORG_NODE}:7051
export CORE_PEER_MSPCONFIGPATH=/orgs/peer-orgs/${ORG_NAME}/users/${ORG_NAME}-admin/msp
export CORE_PEER_TLS_ROOTCERT_FILE=/orgs/peer-orgs/${ORG_NAME}/msp/tlscacerts/tlsca-signcert.pem

# install the chaincode
peer lifecycle chaincode install ${CHAINCODE_PACKAGE_PATH}

