export FABRIC_CFG_PATH=${PWD}configtx

cat $FABRIC_CFG_PATH/configtx.yaml

export CHANNEL_NAME=$1

export ORDERER_ORG_NAME=$2
export ORDERER_ORG_DOMAIN=$3

generate channel genesis block
configtxgen \
  -profile TickenNetworkGenesis \
  -channelID ${CHANNEL_NAME} \
  -outputBlock ./channel-artifacts/${CHANNEL_NAME}_genesis_block.pb

# configtxgen -inspectBlock ./channel-artifacts/${CHANNEL_NAME}_genesis_block.pb

osnadmin channel join \
  --orderer-address ${ORDERER_ORG_NAME}-ord0:9443 \
  --ca-file         ./orgs/ord-orgs/${ORDERER_ORG_NAME}/nodes/ord0.${ORDERER_ORG_DOMAIN}/tls/signcerts/cert.pem \
  --client-cert     ./orgs/ord-orgs/${ORDERER_ORG_NAME}/users/Admin@${ORDERER_ORG_DOMAIN}/msp/signcerts/cert.pem \
  --client-key      ./orgs/ord-orgs/${ORDERER_ORG_NAME}/users/Admin@${ORDERER_ORG_DOMAIN}/msp/keystore/priv.pem \
  --channelID       ${CHANNEL_NAME} \
  --config-block    ./channel-artifacts/${CHANNEL_NAME}_genesis_block.pb
