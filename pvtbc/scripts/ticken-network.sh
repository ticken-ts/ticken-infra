. utils.sh
. deploy-org.sh

export K8_NAMESPACE="ticken-pvtbc-network"

export ORDERER_ORG="orderer"
export TICKEN_ORG="ticken"

export PEER_ORG_TYPE="peerorg"
export ORD_ORG_TYPE="ordorg"

function bootstrap() {
#    echo "*** Deploying orderer org: $ORDERER_ORG ***"
#    initialize_org $ORDERER_ORG $ORD_ORG_TYPE $K8_NAMESPACE
#    echo "*** Orderer org deployed ***"


#    echo "*** Deploying ticken org: $TICKEN_ORG ***"
#    initialize_org $TICKEN_ORG $PEER_ORG_TYPE $K8_NAMESPACE
#    echo "*** Ticken org deployed ***"

#    echo "*** Bootstrapping network ***"
#    kube_apply_template "../k8s/jobs/bootstrap-network-job.yaml" $K8_NAMESPACE
#    kube_wait_until_job_completed "../k8s/jobs/bootstrap-network-job.yaml" $K8_NAMESPACE
#    echo "*** Network bootstrapped ***"

#    echo "*** Deploying orderer node ***"
#    deploy_ord_node $ORDERER_ORG $K8_NAMESPACE
#    echo "*** Orderer node deployed ***"

    echo "*** Deploying peer node ***"
    deploy_peer_node $TICKEN_ORG $ORDERER_ORG $K8_NAMESPACE
    echo "*** Peer node deployed ***"
}

bootstrap
