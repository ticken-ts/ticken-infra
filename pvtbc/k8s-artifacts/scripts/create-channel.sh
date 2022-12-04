export FABRIC_CFG_PATH=${PWD}configtx

cat $FABRIC_CFG_PATH/configtx.yaml

export CHANNEL_NAME=$1

export ORDERER_ORG_NAME=$2
export ORDERER_ORG_DOMAIN=$3

export GENESIS_ORG_NAME="ticken"
export GENESIS_ORG_DOMAIN="ticken.example.com"

# generate channel genesis block
configtxgen \
  -profile TickenNetworkGenesis \
  -channelID ${CHANNEL_NAME} \
  -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}_genesis_block.tx

#peer channel create \
#  -o ${ORDERER_ORG_NAME}-ord0:7050 \
#  -c ${CHANNEL_NAME} \
#  -f ./channel-artifacts/${CHANNEL_NAME}.tx \
#  --outputBlock ./channel-artifacts/${CHANNEL_NAME}_genesis_block.pb \
#  --tls \
#  --cafile ./orgs/ord-orgs/${ORDERER_ORG_NAME}/nodes/ord0.${ORDERER_ORG_DOMAIN}/tls/signcerts/cert.pem


# configtxgen -inspectBlock ./channel-artifacts/${CHANNEL_NAME}_genesis_block.pb

osnadmin channel join \
  --orderer-address ${ORDERER_ORG_NAME}-ord0:9443 \
  --ca-file         ./orgs/ord-orgs/${ORDERER_ORG_NAME}/nodes/ord0.${ORDERER_ORG_DOMAIN}/tls/signcerts/cert.pem \
  --client-cert     ./orgs/ord-orgs/${ORDERER_ORG_NAME}/users/Admin@${ORDERER_ORG_DOMAIN}/msp/signcerts/cert.pem \
  --client-key      ./orgs/ord-orgs/${ORDERER_ORG_NAME}/users/Admin@${ORDERER_ORG_DOMAIN}/msp/keystore/51669f1ee28cdf7bf61483cab62810bbdd6e20e4ac691920ca61c4d03b3f3618_sk \
  --channelID       ${CHANNEL_NAME} \
  --config-block    ./channel-artifacts/${CHANNEL_NAME}_genesis_block.pb
