export GENESIS_ORG_NAME="ticken"
export CHANNEL_NAME="ticken-channel"

export FABRIC_CFG_PATH=${PWD}configtx

function createChannelTx() {
  echo "Generating channel create transaction ${CHANNEL_NAME}.tx"
	set -x

	configtxgen \
	  -profile TwoOrgsChannel \
	  -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx \
	  -channelID $CHANNEL_NAME

	res=$?
	{ set +x; } 2>/dev/null
	if [ $res -ne 0 ]; then
		fatalln "Failed to generate channel configuration transaction..."
	fi
}

function createAnchorPeerTx() {
	echo "Generating anchor peer update transaction for ${GENESIS_ORG_NAME}"
	set -x

	configtxgen \
	  -profile TwoOrgsChannel \
	  -outputAnchorPeersUpdate ./channel-artifacts/${GENESIS_ORG_NAME}anchors.tx \
	  -channelID $CHANNEL_NAME \
	  -asOrg ${GENESIS_ORG_NAME}

	res=$?
	{ set +x; } 2>/dev/null

	if [ $res -ne 0 ]; then
		fatalln "Failed to generate anchor peer update transaction for ${GENESIS_ORG_NAME}..."
	fi
}

createChannelTx
createAnchorPeerTx

exit 0