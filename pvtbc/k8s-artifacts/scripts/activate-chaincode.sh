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

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"
export CORE_PEER_ADDRESS=${ORG_NAME}-${ORG_NODE}:7051
export CORE_PEER_MSPCONFIGPATH=/orgs/peer-orgs/${ORG_NAME}/users/Admin@${ORG_NAME}/msp
export CORE_PEER_TLS_ROOTCERT_FILE=/orgs/peer-orgs/${ORG_NAME}/nodes/${ORG_NODE}.${ORG_NAME}/tls/ca.crt

# install the chaincode
peer lifecycle chaincode install ${CHAINCODE_PACKAGE_PATH}

# approve the chaincode
peer lifecycle chaincode approveformyorg \
  --channelID     ${CHANNEL_NAME} \
  --name          ${CHAINCODE_NAME} \
  --version       1 \
  --package-id    ${CHAINCODE_ID} \
  --sequence      1 \
  --orderer       ${ORDERER_ORG_NAME}-ord0:7050 \
  --tls --cafile  /orgs/ord-orgs/${ORDERER_ORG_NAME}/nodes/ord0.${ORDERER_ORG_NAME}/tls/signcerts/cert.pem

# commit the chaincode
peer lifecycle chaincode commit \
  --channelID     ${CHANNEL_NAME} \
  --name          ${CHAINCODE_NAME} \
  --version       1 \
  --sequence      1 \
  --orderer       ${ORDERER_ORG_NAME}-ord0:7050 \
  --tls --cafile  /orgs/ord-orgs/${ORDERER_ORG_NAME}/nodes/ord0.${ORDERER_ORG_NAME}/tls/signcerts/cert.pem