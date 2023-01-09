. /scripts/utils/org-context.sh

function generate_org_definition() {
  local org_name=$1
  local storage_path=$2

  echo "generation org ${org_name} definition and storing in ${storage_path}/configtx.yaml"

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

function fetch_channel_config() {
  local channel=$1
  local genesis_org=$2
  local orderer=$3
  local config_filename=$4

  echo "fetching ${channel} config using ${genesis_org} and storing in ${config_filename}"

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

function add_org_to_channel_config() {
  local org=$1
  local org_defintion=$2
  local current_channel_config=$3
  local output_modified_config=$4

  local org_msp="${org}MSP"

  jq -s \
    ".[0] * {\"channel_group\":{\"groups\":{\"Application\":{\"groups\": {\"${org_msp}\":.[1]}}}}}" \
    ${current_channel_config} ${org_defintion} > ${output_modified_config}
}


function create_channel_config_update() {
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
  { set +x; } 2>/dev/null
}

function submit_channel_update_transaction() {
  local channel=$1
  local orderer=$2
  local genesis_org=$3
  local update_envelope=$4

  echo "submiting ${channel} update using ${genesis_org}"

  set_peer_org_context $genesis_org

  local orderer_ca_file="/orgs/orderer-orgs/${orderer}/nodes/${orderer}-orderer0/tls/signcerts/tls-cert.pem"

  peer channel update \
    --file ${update_envelope} \
    --orderer ${orderer}-orderer0:7050 \
    --channelID ${channel} \
    --tls --cafile ${orderer_ca_file}
}


CONFIGTX_PATH="/configtx"
mkdir -p $CONFIGTX_PATH

CHANNEL_NAME=$1
JOINING_ORG_NAME=$2
GENESIS_ORG_NAME=$3
ORDERER_ORG_NAME=$4

ORIGINAL_CHANNEL_CONFIG="channel-config-original.json"
MODIFIED_CHANNEL_CONFIG="channel-config-modified.json"

UPDATE_ENVELOPE_OUTPUT="update-channel-envelope.pb"

generate_org_definition $JOINING_ORG_NAME $CONFIGTX_PATH
fetch_channel_config $CHANNEL_NAME $GENESIS_ORG_NAME $ORDERER_ORG_NAME $ORIGINAL_CHANNEL_CONFIG
add_org_to_channel_config $JOINING_ORG_NAME "${CONFIGTX_PATH}/${JOINING_ORG_NAME}.json" $ORIGINAL_CHANNEL_CONFIG $MODIFIED_CHANNEL_CONFIG
create_channel_config_update $CHANNEL_NAME $ORIGINAL_CHANNEL_CONFIG $MODIFIED_CHANNEL_CONFIG $UPDATE_ENVELOPE_OUTPUT
submit_channel_update_transaction $CHANNEL_NAME $ORDERER_ORG_NAME $GENESIS_ORG_NAME $UPDATE_ENVELOPE_OUTPUT
