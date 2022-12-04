. utils.sh

export PEER_NODES_TEMPLATE_PATH="../k8s/org/peer-node"
export ORD_NODES_TEMPLATE_PATH="../k8s/org/ord-node"

export JOBS_TEMPLATES_PATH="../k8s/org/jobs"
export CA_TEMPLATES_PATH="../k8s/org/ca"

function deploy_ca() {
  local k8_namespace=$1

  echo "Deploying organization CA"
  kube_apply_template "$CA_TEMPLATES_PATH/ca-org.yaml" $k8_namespace
  kube_apply_template "$CA_TEMPLATES_PATH/ca-org-service.yaml" $k8_namespace

  kube_wait_until_pod_running "$CA_TEMPLATES_PATH/ca-org.yaml" $k8_namespace
}


function generate_certs() {
    local k8_namespace=$1
    echo "Generating certificates CA"
    kube_apply_template "$JOBS_TEMPLATES_PATH/generate-certs-job.yaml" $k8_namespace
    kube_wait_until_job_completed "$JOBS_TEMPLATES_PATH/generate-certs-job.yaml" $k8_namespace
}

function initialize_org() {
  # used to replace on the kubernetes templates
  export ORG_NAME=$1
  export ORG_TYPE=$2

  local k8_namespace=$3

  deploy_ca $k8_namespace
  generate_certs $k8_namespace
}

function deploy_ord_node() {
  export ORG_NAME=$1
  export ORG_MSP="OrdererMSP"
  export ORG_DOMAIN="$ORG_NAME.example.com"
  local k8_namespace=$2

  kube_apply_template "$ORD_NODES_TEMPLATE_PATH/ord-node.yaml" $k8_namespace
  kube_apply_template "$ORD_NODES_TEMPLATE_PATH/ord-node-service.yaml" $k8_namespace
  kube_wait_until_pod_running "$ORD_NODES_TEMPLATE_PATH/ord-node-service.yaml" $k8_namespace
}

function deploy_peer_node() {
  export ORG_NAME=$1
  export ORD_NAME=$2

  export ORG_MSP="TickenMSP"
  export ORG_DOMAIN="$ORG_NAME.example.com"
  export ORD_DOMAIN="$ORD_NAME.example.com"

  local k8_namespace=$3

  kube_apply_template "$PEER_NODES_TEMPLATE_PATH/peer-configmap.yaml" $k8_namespace
  kube_apply_template "$PEER_NODES_TEMPLATE_PATH/peer-node.yaml" $k8_namespace
  kube_apply_template "$PEER_NODES_TEMPLATE_PATH/peer-node-cli.yaml" $k8_namespace
  kube_apply_template "$PEER_NODES_TEMPLATE_PATH/peer-node-service.yaml" $k8_namespace
  kube_wait_until_pod_running "$PEER_NODES_TEMPLATE_PATH/peer-node-service.yaml" $k8_namespace
}

