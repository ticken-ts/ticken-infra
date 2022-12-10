. utils.sh

function deploy_peer_node() {
  local org_name=$1
  local org_node=$2
  local org_domain=$3
  local k8s_namespace=$4

  export ORG_NAME=$org_name
  export ORG_NODE=$org_node
  export ORG_DOMAIN=$org_domain

  kube_apply_template "$PEER_NODES_TEMPLATE_PATH/peer-configmap.yaml" $k8s_namespace
  kube_apply_template "$PEER_NODES_TEMPLATE_PATH/peer-node.yaml" $k8s_namespace
  kube_apply_template "$PEER_NODES_TEMPLATE_PATH/peer-node-cli.yaml" $k8s_namespace
  kube_apply_template "$PEER_NODES_TEMPLATE_PATH/peer-node-service.yaml" $k8s_namespace
  kube_wait_until_pod_running "$PEER_NODES_TEMPLATE_PATH/peer-node-service.yaml" $k8s_namespace
}

function deploy_ord_node() {
  local org_name=$1
  local org_node=$2
  local org_domain=$3
  local k8s_namespace=$4

  export ORG_NAME=$org_name
  export ORG_NODE=$org_node
  export ORG_DOMAIN=$org_domain

  kube_apply_template "$ORD_NODES_TEMPLATE_PATH/ord-node.yaml" $k8s_namespace
  kube_apply_template "$ORD_NODES_TEMPLATE_PATH/ord-node-service.yaml" $k8s_namespace
  kube_wait_until_pod_running "$ORD_NODES_TEMPLATE_PATH/ord-node-service.yaml" $k8s_namespace
}


function deploy_org_ca() {
  local org_name=$1
  local k8s_namespace=$2

  # the following exports are made
  # to replace in the CA's templates
  export ORG_NAME=$org_name
  export CA_ADMIN_USERNAME="admin"
  export CA_ADMIN_PASSWORD="adminpw"

  kube_apply_template "$CA_TEMPLATES_PATH/ca-org.yaml" $k8s_namespace
  kube_apply_template "$CA_TEMPLATES_PATH/ca-org-service.yaml" $k8s_namespace
  kube_wait_until_pod_running "$CA_TEMPLATES_PATH/ca-org.yaml" $k8s_namespace
}

function generate_ord_org_certs() {
    local org_name=$1
    local org_domain=$2
    local k8s_namespace=$3

    export ORG_NAME=$org_name
    export ORG_DOMAIN=$org_domain
    export CA_ADMIN_USERNAME="admin"
    export CA_ADMIN_PASSWORD="adminpw"

    kube_apply_template "$ORG_JOBS_TEMPLATES_PATH/generate-ord-org-certs-job.yaml" $k8s_namespace
    kube_wait_until_job_completed "$ORG_JOBS_TEMPLATES_PATH/generate-ord-org-certs-job.yaml" $k8s_namespace
}

function generate_peer_org_certs() {
    local org_name=$1
    local org_domain=$2
    local k8s_namespace=$3

    export ORG_NAME=$org_name
    export ORG_DOMAIN=$org_domain
    export CA_ADMIN_USERNAME="admin"
    export CA_ADMIN_PASSWORD="adminpw"

    kube_apply_template "$ORG_JOBS_TEMPLATES_PATH/generate-peer-org-certs-job.yaml" $k8s_namespace
    kube_wait_until_job_completed "$ORG_JOBS_TEMPLATES_PATH/generate-peer-org-certs-job.yaml" $k8s_namespace
}

function deploy_ord_organization() {
  local org_name=$1
  local org_domain=$2
  local k8s_namespace=$3

  # first we need to deploy CA's and generate certificates
  deploy_org_ca $org_name $k8s_namespace

  # after CA's are deployed, we trigger a job to generate
  # the organization's crypto material using the CA
  generate_ord_org_certs $org_name $org_domain $k8s_namespace

  # once the certificated are generated, it's time
  # to deploy de orderer nodes
  deploy_ord_node $org_name "ord0" $org_domain $k8s_namespace
}

function deploy_peer_organization() {
  local org_name=$1
  local org_domain=$2
  local k8s_namespace=$3

  # first we need to deploy CA's and generate certificates
  deploy_org_ca $org_name $k8s_namespace

  # after CA's are deployed, we trigger a job to generate
  # the organization's crypto material using the CA
  generate_peer_org_certs $org_name $org_domain $k8s_namespace

  # once the certificated are generated, it's time
  # to deploy de orderer nodes
  deploy_peer_node $org_name "peer0" $org_domain $k8s_namespace
}