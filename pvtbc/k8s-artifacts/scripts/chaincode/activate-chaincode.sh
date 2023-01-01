# Convenience routine to "do everything other than package and launch" a sample CC.
# When debugging a chaincode server, the process must be launched prior to completing
# the chaincode lifecycle at the peer.  This routine provides a route for packaging
# and installing the chaincode out of band, and a single target to complete the peer
# chaincode lifecycle.

CHANNEL_NAME=$1
ORG_NAME=$2
ORG_NODE=$3
ORDERER_ORG_NAME=$4
CHAINCODE_ID=$5
CHAINCODE_NAME=$6

CHAINCODE_PACKAGE_PATH="/chaincodes/${ORG_NAME}/${CHAINCODE_NAME}.tgz"

export FABRIC_CFG_PATH=/config
export CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"
export CORE_PEER_ADDRESS=${ORG_NAME}-${ORG_NODE}:7051
export CORE_PEER_MSPCONFIGPATH=/orgs/peer-orgs/${ORG_NAME}/users/${ORG_NAME}-admin/msp
export CORE_PEER_TLS_ROOTCERT_FILE=/orgs/peer-orgs/${ORG_NAME}/msp/tlscacerts/tlsca-signcert.pem


# install the chaincode
peer lifecycle chaincode install ${CHAINCODE_PACKAGE_PATH}

# approve the chaincode
peer lifecycle chaincode approveformyorg \
  --channelID     ${CHANNEL_NAME} \
  --name          ${CHAINCODE_NAME} \
  --package-id    ${CHAINCODE_ID} \
  --version       1 \
  --sequence      1 \
  --orderer       ${ORDERER_ORG_NAME}-orderer0:7050 \
  --tls --cafile   /orgs/orderer-orgs/${ORDERER_ORG_NAME}/nodes/${ORDERER_ORG_NAME}-orderer0/tls/signcerts/tls-cert.pem

# commit the chaincode
peer lifecycle chaincode commit \
  --channelID     ${CHANNEL_NAME} \
  --name          ${CHAINCODE_NAME} \
  --version       1 \
  --sequence      1 \
  --orderer       ${ORDERER_ORG_NAME}-orderer0:7050 \
  --tls --cafile   /orgs/orderer-orgs/${ORDERER_ORG_NAME}/nodes/${ORDERER_ORG_NAME}-orderer0/tls/signcerts/tls-cert.pem