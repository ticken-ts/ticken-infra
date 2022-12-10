. utils.sh
. channel.sh
. chaincode.sh
. deploy-org.sh

readonly K8_NAMESPACE="ticken-pvtbc-network"

readonly PEER_NODES_TEMPLATE_PATH="../k8s/org/peer-node"
readonly ORD_NODES_TEMPLATE_PATH="../k8s/org/ord-node"
readonly ORG_JOBS_TEMPLATES_PATH="../k8s/org/jobs"
readonly COMMON_JOBS_TEMPLATES_PATH="../k8s/jobs"
readonly CHAINCODE_TEMPLATE_PATH="../k8s/org/chaincode"

readonly CA_TEMPLATES_PATH="../k8s/org/ca"

export CHANNEL_NAME="ticken-channel"

export GENESIS_ORG_NAME="ticken"
export GENESIS_ORG_DOMAIN="ticken.example.com"

export ORDERER_ORG_NAME="orderer"
export ORDERER_ORG_DOMAIN="orderer.example.com"

readonly TICKEN_EVENT_CHAINCODE_NAME="ticken-event-chaincode"
readonly TICKEN_EVENT_CHAINCODE_PATH="../../../ticken-chaincodes/ticken-event-chaincode"

readonly TICKEN_TICKET_CHAINCODE_NAME="ticken-ticket-chaincode"
readonly TICKEN_TICKET_CHAINCODE_PATH="../../../ticken-chaincodes/ticken-event-chaincode"

context LOCAL_REGISTRY_NAME           kind-registry
context LOCAL_REGISTRY_INTERFACE      127.0.0.1
context LOCAL_REGISTRY_PORT           5000

function bootstrap() {
    echo "*** Deploying orderer org: $ORDERER_ORG ***"
    deploy_ord_organization $ORDERER_ORG_NAME $ORDERER_ORG_DOMAIN $K8_NAMESPACE
    echo "*** Orderer org deployed ***"

    echo "*** Deploying genesis org: $TICKEN_ORG ***"
    deploy_peer_organization $GENESIS_ORG_NAME $GENESIS_ORG_DOMAIN $K8_NAMESPACE
    echo "*** Genesis org deployed ***"

    # todo -> this should be done inside the kubernetes job
    # that instantiates de CA's and the certificates
    sh ../k8s-artifacts/scripts/utils/rename-priv-keys.sh /tmp/ticken-pv/orgs/ord-orgs priv.pem
    sh ../k8s-artifacts/scripts/utils/rename-priv-keys.sh /tmp/ticken-pv/orgs/peer-orgs priv.pem

    echo "*** Creating channel: ${CHANNEL_NAME} ***"
    create_channel $CHANNEL_NAME $ORDERER_ORG_NAME $ORDERER_ORG_DOMAIN $K8_NAMESPACE
    echo "*** Channel created ***"

    echo "*** Joining channel: ${CHANNEL_NAME} ***"
    join_channel $CHANNEL_NAME $GENESIS_ORG_NAME $GENESIS_ORG_DOMAIN $ORDERER_ORG_NAME $ORDERER_ORG_DOMAIN $K8_NAMESPACE
    echo "*** Channel joined ***"

    echo "*** Deploying contracts in org: $GENESIS_ORG_NAME ***"
    deploy_chaincode \
      $GENESIS_ORG_NAME $GENESIS_ORG_DOMAIN $CHANNEL_NAME \
      $TICKEN_EVENT_CHAINCODE_NAME $TICKEN_EVENT_CHAINCODE_PATH \
      $ORDERER_ORG_NAME $ORDERER_ORG_DOMAIN \
      $K8_NAMESPACE
#
    deploy_chaincode \
      $GENESIS_ORG_NAME $GENESIS_ORG_DOMAIN $CHANNEL_NAME \
      $TICKEN_TICKEN_TICKET_CHAINCODE_NAME $TICKEN_TICKEN_TICKET_CHAINCODE_PATH \
      $ORDERER_ORG_NAME $ORDERER_ORG_DOMAIN \
      $K8_NAMESPACE
    echo "*** Chaincode deployed ***"
}

bootstrap
