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

    log_op "Deploying org: $org_name"
    deploy_org $org_name $PEER_ORG_TYPE
    log_op "Deployed org: $org_name"

    _rename_privs

    log_op "Joining channel: $CHANNEL_NAME"
    join_channel $TICKEN_CHANNEL_NAME $org_name $ORDERER_ORG_NAME
    log_op "Channel joined"

    log_op "Installing contract $TICKEN_EVENT_CHAINCODE_NAME in $org_name"
    install_chaincode $TICKEN_EVENT_CHAINCODE_NAME $org_name
    log_op "$TICKEN_EVENT_CHAINCODE_NAME deployed"

    log_op "Installing contract $TICKEN_TICKET_CHAINCODE_NAME in $org_name"
    install_chaincode $TICKEN_TICKET_CHAINCODE_NAME $org_name
    log_op "$TICKEN_TICKET_CHAINCODE_NAME deployed"
}

function bootstrap() {
  log_op "Starting cluster"
  ticken_cluster_init
  log_op "Cluster running"

  log_op "Deploying org: $ORDERER_ORG_NAME"
  deploy_org $ORDERER_ORG_NAME $ORDERER_ORG_TYPE
  log_op "Deployed org: $ORDERER_ORG_NAME \n"

  log_op "Deploying org: $GENESIS_ORG_NAME"
  deploy_org $GENESIS_ORG_NAME $PEER_ORG_TYPE
  log_op "Deployed org: $GENESIS_ORG_NAME \n"

  _rename_privs

  log_op "Creating channel: $TICKEN_CHANNEL_NAME"
  create_channel $TICKEN_CHANNEL_NAME $ORDERER_ORG_NAME
  log_op "Channel created: $TICKEN_CHANNEL_NAME \n"

  log_op "Joining channel: $CHANNEL_NAME"
  join_channel $TICKEN_CHANNEL_NAME $GENESIS_ORG_NAME $ORDERER_ORG_NAME
  log_op "Channel joined \n"

  log_op "Deploying contract $TICKEN_EVENT_CHAINCODE_NAME in $org_name"
  deploy_chaincode \
    $TICKEN_CHANNEL_NAME \
    $GENESIS_ORG_NAME $ORDERER_ORG_NAME \
    $TICKEN_EVENT_CHAINCODE_NAME $TICKEN_EVENT_CHAINCODE_PATH
  log_op "$TICKEN_EVENT_CHAINCODE_NAME deployed \n"

  log_op "Deploying contract $TICKEN_TICKET_CHAINCODE_NAME in $org_name"
  deploy_chaincode \
    $TICKEN_CHANNEL_NAME \
    $GENESIS_ORG_NAME $ORDERER_ORG_NAME \
    $TICKEN_TICKET_CHAINCODE_NAME $TICKEN_TICKET_CHAINCODE_PATH
  log_op "$TICKEN_TICKET_CHAINCODE_NAME deployed \n"
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