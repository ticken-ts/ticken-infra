. /scripts/utils/org-context.sh

function _generate_org_definition() {
  local org_name=$1
  local storage_path=$2

  local org_msp="${org_name}MSP"

  echo "
    Organizations:
      - &${org_name}

        # DefaultOrg defines the organization which is used in the sampleconfig
        # of the fabric.git development environment
        Name: ${org_msp}

        # ID to load the MSP definition as
        ID: ${org_msp}

        MSPDir: /orgs/peer-orgs/${org_name}/msp

        Policies:
            Readers:
                Type: Signature
                Rule: \"OR('${org_msp}.admin', '${org_msp}.peer', '${org_msp}.client')\"
            Writers:
                Type: Signature
                Rule: \"OR('${org_msp}.admin', '${org_msp}.client')\"
            Admins:
                Type: Signature
                Rule: \"OR('${org_msp}.admin')\"
            Endorsement:
                Type: Signature
                Rule: \"OR('${org_msp}.peer')\"" > ${storage_path}/configtx.yaml

  FABRIC_CFG_PATH=${storage_path} configtxgen -printOrg ${org_msp} > ${storage_path}/${org_name}.json
}

function _fetch_channel_config() {
  local channel=$1
  local genesis_org=$2
  local orderer=$3
  local config_filename=$4

  set_peer_org_context $genesis_org

  local orderer_ca_file="/orgs/orderer-orgs/${orderer}/nodes/${orderer}-orderer0/tls/signcerts/tls-cert.pem"

  peer channel fetch config config_block.pb \
    --orderer ${orderer}  \
    --channelID ${channel} \
    --tls --cafile ${orderer_ca_file}

  configtxlator proto_decode \
    --input config_block.pb \
    --type common.Block \
    --output config_block.json

  jq .data.data[0].payload.data.config config_block.json > "${config_filename}"
}

function _add_org_to_channel_config() {
  local org=$1
  local org_definition=$2
  local current_channel_config=$3
  local output_modified_config=$4

  local org_msp="${org}MSP"

  jq -s \
    ".[0] * {\"channel_group\":{\"groups\":{\"Application\":{\"groups\": {\"${org_msp}\":.[1]}}}}}" \
    ${current_channel_config} ${org_definition} > ${output_modified_config}
}

function _add_anchor_peer_to_channel_config() {
  local org=$1
  local node=$2
  local current_channel_config=$3
  local output_modified_config=$4

  local peer_port=7051
  local peer_host="${org}-${node}"

  local org_msp="${org}MSP"

  jq '.channel_group.groups.Application.groups.'${org_msp}'.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "'${peer_host}'","port": '${peer_port}'}]},"version": "0"}}' \
  ${current_channel_config} > ${output_modified_config}
}


function _create_channel_config_update() {
  CHANNEL=$1
  ORIGINAL=$2
  MODIFIED=$3
  OUTPUT=$4

  configtxlator proto_encode --input "${ORIGINAL}" --type common.Config --output original_config.pb
  configtxlator proto_encode --input "${MODIFIED}" --type common.Config --output modified_config.pb
  configtxlator compute_update --channel_id "${CHANNEL}" --original original_config.pb --updated modified_config.pb --output config_update.pb
  configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json
  echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . >config_update_in_envelope.json
  configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output "${OUTPUT}"
}

function _submit_channel_update_transaction() {
  local channel=$1
  local orderer=$2
  local submiter_org=$3
  local update_envelope=$4

  set_peer_org_context $submiter_org

  local orderer_ca_file="/orgs/orderer-orgs/${orderer}/nodes/${orderer}-orderer0/tls/signcerts/tls-cert.pem"

  peer channel update \
    --file ${update_envelope} \
    --orderer ${orderer}-orderer0:7050 \
    --channelID ${channel} \
    --tls --cafile ${orderer_ca_file}
}

function add_org_to_channel() {
  local org_name=$1
  local channel=$2
  local genesis_org_name=$3
  local orderer_org_name=$4

  CONFIGTX_PATH="/configtx"
  mkdir -p $CONFIGTX_PATH

  ORG_DEFINITION_FILE="${CONFIGTX_PATH}/${org_name}.json"
  ORIGINAL_CHANNEL_CONFIG="channel-config-current.json"
  MODIFIED_CHANNEL_CONFIG="channel-config-modified.json"
  UPDATE_ENVELOPE_OUTPUT="update-channel-envelope.pb"

  _generate_org_definition $org_name $CONFIGTX_PATH
  _fetch_channel_config $channel $genesis_org_name $orderer_org_name $ORIGINAL_CHANNEL_CONFIG
  _add_org_to_channel_config $org_name $ORG_DEFINITION_FILE $ORIGINAL_CHANNEL_CONFIG $MODIFIED_CHANNEL_CONFIG
  _create_channel_config_update $channel $ORIGINAL_CHANNEL_CONFIG $MODIFIED_CHANNEL_CONFIG $UPDATE_ENVELOPE_OUTPUT
  _submit_channel_update_transaction $channel $orderer_org_name $genesis_org_name $UPDATE_ENVELOPE_OUTPUT

  rm $ORIGINAL_CHANNEL_CONFIG
  rm $MODIFIED_CHANNEL_CONFIG
  rm $UPDATE_ENVELOPE_OUTPUT
}

function set_org_anchor_peer() {
  set -x
  local org_name=$1
  local channel=$2
  local genesis_org_name=$3
  local orderer_org_name=$4

  ORIGINAL_CHANNEL_CONFIG="channel-config-current.json"
  MODIFIED_CHANNEL_CONFIG="channel-config-modified.json"
  UPDATE_ENVELOPE_OUTPUT="update-channel-envelope.pb"

  _fetch_channel_config $channel $genesis_org_name $orderer_org_name $ORIGINAL_CHANNEL_CONFIG
  _add_anchor_peer_to_channel_config $org_name "peer0" $ORIGINAL_CHANNEL_CONFIG $MODIFIED_CHANNEL_CONFIG

  cat $MODIFIED_CHANNEL_CONFIG

  _create_channel_config_update $channel $ORIGINAL_CHANNEL_CONFIG $MODIFIED_CHANNEL_CONFIG $UPDATE_ENVELOPE_OUTPUT
  _submit_channel_update_transaction $channel $orderer_org_name $org_name $UPDATE_ENVELOPE_OUTPUT

  rm $ORIGINAL_CHANNEL_CONFIG
  rm $MODIFIED_CHANNEL_CONFIG
  rm $UPDATE_ENVELOPE_OUTPUT
}

CHANNEL_NAME=$1
JOINING_ORG_NAME=$2
GENESIS_ORG_NAME=$3
ORDERER_ORG_NAME=$4

add_org_to_channel $JOINING_ORG_NAME $CHANNEL_NAME $GENESIS_ORG_NAME $ORDERER_ORG_NAME
set_org_anchor_peer $JOINING_ORG_NAME $CHANNEL_NAME $GENESIS_ORG_NAME $ORDERER_ORG_NAME