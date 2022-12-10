. utils.sh

function _deploy_org_ca() {
  local org_name=$1

  export ORG_NAME=$org_name
  export CA_ADMIN_USERNAME="admin"
  export CA_ADMIN_PASSWORD="adminpw"

  kube_apply_template "$K8S_CA_FILES_PATH/ca-org.yaml" $CLUSTER_NAMESPACE
  kube_apply_template "$K8S_CA_FILES_PATH/ca-org-service.yaml" $CLUSTER_NAMESPACE
  kube_wait_until_pod_running "$K8S_CA_FILES_PATH/ca-org.yaml" $CLUSTER_NAMESPACE
}

function _generate_ord_org_certs() {
    local org_name=$1

    export ORG_NAME=$org_name
    export CA_ADMIN_USERNAME="admin"
    export CA_ADMIN_PASSWORD="adminpw"

    kube_apply_template "$K8S_ORG_JOBS_PATH/generate-ord-org-certs-job.yaml" $CLUSTER_NAMESPACE
    kube_wait_until_job_completed "$K8S_ORG_JOBS_PATH/generate-ord-org-certs-job.yaml" $CLUSTER_NAMESPACE
}

function _generate_peer_org_certs() {
    local org_name=$1

    export ORG_NAME=$org_name
    export CA_ADMIN_USERNAME="admin"
    export CA_ADMIN_PASSWORD="adminpw"

    kube_apply_template "$K8S_ORG_JOBS_PATH/generate-peer-org-certs-job.yaml" $CLUSTER_NAMESPACE
    kube_wait_until_job_completed "$K8S_ORG_JOBS_PATH/generate-peer-org-certs-job.yaml" $CLUSTER_NAMESPACE
}

function _deploy_ord_node() {
  local org_name=$1
  local org_node=$2

  export ORG_NAME=$org_name
  export ORG_NODE=$org_node

  kube_apply_template "$K8S_ORG_ORD_NODES_PATH/ord-node.yaml" $CLUSTER_NAMESPACE
  kube_apply_template "$K8S_ORG_ORD_NODES_PATH/ord-node-service.yaml" $CLUSTER_NAMESPACE
  kube_wait_until_pod_running "$K8S_ORG_ORD_NODES_PATH/ord-node-service.yaml" $CLUSTER_NAMESPACE
}

function _deploy_peer_node() {
  local org_name=$1
  local org_node=$2

  export ORG_NAME=$org_name
  export ORG_NODE=$org_node

  kube_apply_template "$K8S_ORG_PEER_NODES_PATH/peer-configmap.yaml" $CLUSTER_NAMESPACE
  kube_apply_template "$K8S_ORG_PEER_NODES_PATH/peer-node.yaml" $CLUSTER_NAMESPACE
  kube_apply_template "$K8S_ORG_PEER_NODES_PATH/peer-node-cli.yaml" $CLUSTER_NAMESPACE
  kube_apply_template "$K8S_ORG_PEER_NODES_PATH/peer-node-service.yaml" $CLUSTER_NAMESPACE
  kube_wait_until_pod_running "$K8S_ORG_PEER_NODES_PATH/peer-node-service.yaml" $CLUSTER_NAMESPACE
}


function deploy_ord_organization() {
  local org_name=$1
  local orderer_node="ord0"

  # first we need to deploy CA's and generate certificates
  _deploy_org_ca $org_name

  # after CA's are deployed, we trigger a job to generate
  # the organization's crypto material using the CA
  _generate_ord_org_certs $org_name

  # once the certificated are generated, it's time
  # to deploy de orderer nodes
  _deploy_ord_node $org_name $orderer_node
}

function deploy_peer_organization() {
  local org_name=$1
  local peer_node="peer0"

  # first we need to deploy CA's and generate certificates
  _deploy_org_ca $org_name

  # after CA's are deployed, we trigger a job to generate
  # the organization's crypto material using the CA
  _generate_peer_org_certs $org_name

  # once the certificated are generated, it's time
  # to deploy de orderer nodes
  _deploy_peer_node $org_name $peer_node
}