. const.sh
. logs.sh
. utils.sh
. cluster.sh
. channel.sh
. chaincode.sh
. organization.sh

# enables the "errexit" option, which causes the shell to exit
# immediately if a command exits with a non-zero exit status.
set -o errexit

# Initialize the logging system - control output to 'network.log'
# and everything else to 'network-debug.log'
logging_init

function bootstrap_peer_org() {
    local org_name=$1
    local channel_name="${GENESIS_ORG_NAME}-${org_name}-channel"

    log_op "Deploying org: $org_name"
    deploy_org $org_name $PEER_ORG_TYPE
    log_op "Deployed org: $org_name \n"

    _rename_privs

    log_op "Creating channel: $channel_name"
    create_event_channel $GENESIS_ORG_NAME $org_name $ORDERER_ORG_NAME
    log_op "Channel created: $channel_name \n"

    log_op "Joining channel: $channel_name"
    org_peers_join_channel $channel_name $GENESIS_ORG_NAME $ORDERER_ORG_NAME
    log_op "Channel joined \n"

    log_op "Joining channel: $channel_name"
    org_peers_join_channel $channel_name $org_name $ORDERER_ORG_NAME
    log_op "Channel joined \n"

    log_op "Chaincode lifecycle: $TICKEN_EVENT_CHAINCODE_NAME"
    deploy_chaincode_service $org_name $TICKEN_EVENT_CHAINCODE_NAME $ORDERER_ORG_NAME
    install_chaincode_in_peers $org_name $TICKEN_EVENT_CHAINCODE_NAME
    approve_chaincode_in_channel $channel_name $org_name $TICKEN_EVENT_CHAINCODE_NAME $ORDERER_ORG_NAME
    log_op "Chaincode lifecycle completed: $TICKEN_EVENT_CHAINCODE_NAME \n"

    log_op "Chaincode lifecycle: $TICKEN_TICKET_CHAINCODE_NAME"
    deploy_chaincode_service $org_name $TICKEN_TICKET_CHAINCODE_NAME $ORDERER_ORG_NAME
    install_chaincode_in_peers $org_name $TICKEN_TICKET_CHAINCODE_NAME
    approve_chaincode_in_channel $channel_name $org_name $TICKEN_TICKET_CHAINCODE_NAME $ORDERER_ORG_NAME
    log_op "Chaincode lifecycle completed: $TICKEN_TICKET_CHAINCODE_NAME \n"

    log_op "$GENESIS_ORG_NAME approving chaincode: $TICKEN_EVENT_CHAINCODE_NAME"
    approve_chaincode_in_channel $channel_name $GENESIS_ORG_NAME $TICKEN_EVENT_CHAINCODE_NAME $ORDERER_ORG_NAME
    log_op "Chaincode approved: $TICKEN_TICKET_CHAINCODE_NAME \n"

    log_op "$GENESIS_ORG_NAME approving chaincode: $TICKEN_EVENT_CHAINCODE_NAME"
    approve_chaincode_in_channel $channel_name $GENESIS_ORG_NAME $TICKEN_TICKET_CHAINCODE_NAME $ORDERER_ORG_NAME
    log_op "Chaincode approved: $TICKEN_TICKET_CHAINCODE_NAME \n"

    log_op "Committing chaincode in channel: $TICKEN_EVENT_CHAINCODE_NAME"
    commit_chaincode_in_channel $channel_name $TICKEN_EVENT_CHAINCODE_NAME \
      $GENESIS_ORG_NAME $org_name $ORDERER_ORG_NAME
    log_op "Chaincode committed: $TICKEN_EVENT_CHAINCODE_NAME"

    log_op "Committing chaincode in channel: $TICKEN_TICKET_CHAINCODE_NAME"
    commit_chaincode_in_channel $channel_name $TICKEN_TICKET_CHAINCODE_NAME \
      $GENESIS_ORG_NAME $org_name $ORDERER_ORG_NAME
    log_op "Chaincode committed: $TICKEN_TICKET_CHAINCODE_NAME"
}

function bootstrap() {
  log_op "Starting cluster"
  ticken_cluster_init
  log_op "Cluster running \n"

  log_op "Deploying org: $ORDERER_ORG_NAME"
  deploy_org $ORDERER_ORG_NAME $ORDERER_ORG_TYPE
  log_op "Deployed org: $ORDERER_ORG_NAME \n"

  log_op "Deploying org: $GENESIS_ORG_NAME"
  deploy_org $GENESIS_ORG_NAME $PEER_ORG_TYPE
  log_op "Deployed org: $GENESIS_ORG_NAME \n"

  log_op "Preparing chaincode images"
  prepare_chaincode_image $TICKEN_EVENT_CHAINCODE_NAME $TICKEN_EVENT_CHAINCODE_PATH
  prepare_chaincode_image $TICKEN_TICKET_CHAINCODE_NAME $TICKEN_TICKET_CHAINCODE_PATH
  log_op "Chaincode images prepared \n"

  log_op "Deploying chaincode services"
  deploy_chaincode_service $GENESIS_ORG_NAME $TICKEN_EVENT_CHAINCODE_NAME $ORDERER_ORG_NAME
  deploy_chaincode_service $GENESIS_ORG_NAME $TICKEN_TICKET_CHAINCODE_NAME $ORDERER_ORG_NAME
  log_op "Chaincode services deployed \n"

  log_op "Installing chaincodes"
  install_chaincode_in_peers $GENESIS_ORG_NAME $TICKEN_EVENT_CHAINCODE_NAME
  install_chaincode_in_peers $GENESIS_ORG_NAME $TICKEN_TICKET_CHAINCODE_NAME
  log_op "Chaincodes installed \n"
}

function armaggedon() {
  log_op "stopping cluster"
  ticken_cluster_delete
  log_op "cluster stopped \n"
}

MODE=$1

if [ "${MODE}" == "bootstrap" ]; then
  log_title "⛓️ - Bootstrapping Ticken network - ⛓ "
  bootstrap
  log_title "🏁 - Ticken network running - 🏁 "
fi

if [ "${MODE}" == "bootstrap-peer-org" ]; then
  log_title "⛓️ - Bootstrapping peer org - ⛓ "
  bootstrap_peer_org $2
  log_title "🏁 - Ticken network running - 🏁 "
fi

if [ "${MODE}" == "armaggedon" ]; then
  log_title "🔥 - Destroying Ticken network - 🔥 "
  armaggedon
  log_title "🏁 - Ticken network destroyed - 🏁 "
fi