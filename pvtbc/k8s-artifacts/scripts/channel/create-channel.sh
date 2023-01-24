export FABRIC_CFG_PATH=${PWD}configtx

CHANNEL_NAME=$1
NETWORK_PROFILE=$2
ORDERER_ORG_NAME=$3

# generate channel genesis block
configtxgen \
  -profile ${NETWORK_PROFILE} \
  -channelID ${CHANNEL_NAME} \
  -outputBlock ./channel-artifacts/${CHANNEL_NAME}_genesis_block.pb

# The client certificate presented in this case is the admin user's enrollment key.  This is a stronger assertion
# of identity than the Docker Compose network, which transmits the orderer node's TLS key pair directly
osnadmin channel join \
  --orderer-address ${ORDERER_ORG_NAME}-orderer0:9443 \
  --ca-file         ./orgs/orderer-orgs/${ORDERER_ORG_NAME}/nodes/${ORDERER_ORG_NAME}-orderer0/tls/signcerts/tls-cert.pem \
  --client-cert     ./orgs/orderer-orgs/${ORDERER_ORG_NAME}/users/${ORDERER_ORG_NAME}-admin/msp/signcerts/cert.pem \
  --client-key      ./orgs/orderer-orgs/${ORDERER_ORG_NAME}/users/${ORDERER_ORG_NAME}-admin/msp/keystore/priv.pem \
  --channelID       ${CHANNEL_NAME} \
  --config-block    ./channel-artifacts/${CHANNEL_NAME}_genesis_block.pb