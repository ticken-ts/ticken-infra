. const.sh
. cluster.sh
. utils.sh
. channel.sh
. chaincode.sh
. organization.sh

function _rename() {
  # todo -> this should be done inside the kubernetes job that instantiates de CA's and the certificates
  sh ../k8s-artifacts/scripts/utils/rename-priv-keys.sh /tmp/ticken-pv/orgs/ord-orgs priv.pem
  sh ../k8s-artifacts/scripts/utils/rename-priv-keys.sh /tmp/ticken-pv/orgs/peer-orgs priv.pem
}

function bootstrap() {
    echo "*** Starting cluster ***"
    ticken_cluster_init
    echo "*** Cluster started ***"

    echo "*** Deploying orderer org: $ORDERER_ORG_NAME ***"
    deploy_ord_organization $ORDERER_ORG_NAME
    echo "*** Orderer org deployed ***"

    echo "*** Deploying genesis org: $GENESIS_ORG_NAME ***"
    deploy_peer_organization $GENESIS_ORG_NAME
    echo "*** Genesis org deployed ***"

    _rename

    echo "*** Creating channel: $TICKEN_CHANNEL_NAME ***"
    create_channel $TICKEN_CHANNEL_NAME $ORDERER_ORG_NAME
    echo "*** Channel created ***"

    echo "*** Joining channel: ${CHANNEL_NAME} ***"
    join_channel $TICKEN_CHANNEL_NAME $GENESIS_ORG_NAME
    echo "*** Channel joined ***"

    echo "*** Deploying contracts in org: $GENESIS_ORG_NAME ***"
    deploy_chaincode \
      $GENESIS_ORG_NAME $GENESIS_ORG_DOMAIN $CHANNEL_NAME \
      $TICKEN_EVENT_CHAINCODE_NAME $TICKEN_EVENT_CHAINCODE_PATH \
      $ORDERER_ORG_NAME $ORDERER_ORG_DOMAIN \
      $K8_NAMESPACE
#
#    deploy_chaincode \
#      $GENESIS_ORG_NAME $GENESIS_ORG_DOMAIN $CHANNEL_NAME \
#      $TICKEN_TICKEN_TICKET_CHAINCODE_NAME $TICKEN_TICKEN_TICKET_CHAINCODE_PATH \
#      $ORDERER_ORG_NAME $ORDERER_ORG_DOMAIN \
#      $K8_NAMESPACE
#    echo "*** Chaincode deployed ***"
}

bootstrap
