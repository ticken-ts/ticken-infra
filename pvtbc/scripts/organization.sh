function _load_org_config() {
  local org_name=$1
  local org_type=$2

  push_step "$org_name - loading config"

  kubectl -n $CLUSTER_NAMESPACE delete configmap ${org_name}-config || true
  kubectl -n $CLUSTER_NAMESPACE create configmap ${org_name}-config --from-file=${K8S_ORG_CONFIG}/${org_type}

  pop_step
}

function _launch_org_tls_cert_issuer() {
  local org_name=$1

  push_step "$org_name - launching TLS certificate issuer"

  export ORG_NAME=$org_name

  kube_apply_template "../k8s/org/tls/org-tls-cert-issuer.yaml" $CLUSTER_NAMESPACE
  kubectl -n $CLUSTER_NAMESPACE wait --timeout=30s --for=condition=Ready issuer/${org_name}-tls-cert-issuer

  pop_step
}

function _deploy_org_ca() {
  local org_name=$1
  local org_type=$2

  push_step "$org_name - launching Fabric CA"

  export ORG_NAME=$org_name
  export ORG_TYPE=$org_type

  kube_apply_template "$K8S_CA_FILES_PATH/ca-org.yaml" $CLUSTER_NAMESPACE
  kube_apply_template "$K8S_CA_FILES_PATH/ca-org-service.yaml" $CLUSTER_NAMESPACE
  kubectl -n $CLUSTER_NAMESPACE rollout status deploy/${org_name}-ca

  pop_step
}

function _enroll_root_ca_user() {
  local org_name=$1
  local org_type=$2

  push_step "$org_name - enrolling root CA user"

  export ORG_NAME=$org_name
  export ORG_TYPE=$org_type
  export RCAADMIN_USER="rcaadmin"
  export RCAADMIN_PASS="rcaadminpw"

  kube_apply_template "$K8S_ORG_JOBS_PATH/enroll-root-ca-admin.yaml" $CLUSTER_NAMESPACE
  kube_wait_until_job_completed "$K8S_ORG_JOBS_PATH/enroll-root-ca-admin.yaml" $CLUSTER_NAMESPACE

  pop_step
}

function _create_org_msp() {
  local org_name=$1
  local org_type=$2

  push_step "$org_name - creating org msp"

  CA_NAME=${org_name}-ca
  ORG_MSP_DIR=${CLUSTER_VOLUME_PATH}/orgs/${org_type}-orgs/${org_name}/msp

  mkdir -p ${ORG_MSP_DIR}/cacerts
  mkdir -p ${ORG_MSP_DIR}/tlscacerts

  # extract the CA's TLS CA certificate from the cert-manager secret
  kubectl -n $CLUSTER_NAMESPACE get secret ${CA_NAME}-tls-cert -o json \
    | jq -r .data.\"ca.crt\" \
    | base64 -d \
    > ${ORG_MSP_DIR}/tlscacerts/tlsca-signcert.pem

  # extract the CA's signing authority from the CA/cainfo response
  curl -s \
    --cacert ${ORG_MSP_DIR}/tlscacerts/tlsca-signcert.pem \
    https://${CA_NAME}.${DOMAIN}:${NGINX_HTTPS_PORT}/cainfo \
    | jq -r .result.CAChain \
    | base64 -d \
    > ${ORG_MSP_DIR}/cacerts/ca-signcert.pem

  # generate config.yaml
  echo "NodeOUs:
    Enable: true
    ClientOUIdentifier:
      Certificate: cacerts/ca-signcert.pem
      OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
      Certificate: cacerts/ca-signcert.pem
      OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
      Certificate: cacerts/ca-signcert.pem
      OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
      Certificate: cacerts/ca-signcert.pem
      OrganizationalUnitIdentifier: orderer" > ${ORG_MSP_DIR}/config.yaml

  pop_step
}




function _enroll_node_admin() {
  local org_name=$1
  local org_type=$2
  local org_node=$3

  push_step "enrolling $org_name node admin - for node $org_node"

  export ORG_NAME=$org_name
  export ORG_TYPE=$org_type
  export ORG_NODE=$org_node
  export RCAADMIN_USER="rcaadmin"

  kube_apply_template "$K8S_ORG_JOBS_PATH/enroll-node-admin.yaml" $CLUSTER_NAMESPACE
  kube_wait_until_job_completed "$K8S_ORG_JOBS_PATH/enroll-node-admin.yaml" $CLUSTER_NAMESPACE

  pop_step
}

function _enroll_org_user() {
    local org_name=$1
    local org_type=$2
    local user_name=$3
    local user_type=$4

    push_step "enrolling $org_name $user_type user - with username $user_name"

    export ORG_NAME=$org_name
    export ORG_TYPE=$org_type
    export USER_NAME=$user_name
    export USER_TYPE=$user_type
    export RCAADMIN_USER="rcaadmin"

    kube_apply_template "$K8S_ORG_JOBS_PATH/enroll-org-user.yaml" $CLUSTER_NAMESPACE
    kube_wait_until_job_completed "$K8S_ORG_JOBS_PATH/enroll-org-user.yaml" $CLUSTER_NAMESPACE

    pop_step
}

function _deploy_node() {
  local org_name=$1
  local org_type=$2
  local org_node=$3

  push_step "deploying orderer node $org_node in org $org_name"

  export ORG_NAME=$org_name
  export ORG_NODE=$org_node

  kube_apply_template "$K8S_ORG_NODES_PATH/${org_type}/node.yaml" $CLUSTER_NAMESPACE
  kube_apply_template "$K8S_ORG_NODES_PATH/${org_type}/node-service.yaml" $CLUSTER_NAMESPACE
  kubectl -n $CLUSTER_NAMESPACE rollout status deploy/${org_name}-${org_node}

  ORG_NODE_TLS_DIR=${CLUSTER_VOLUME_PATH}/orgs/${org_type}-orgs/${org_name}/nodes/${org_name}-${org_node}/tls/signcerts

  mkdir -p $ORG_NODE_TLS_DIR
  kubectl -n $CLUSTER_NAMESPACE get secret ${org_name}-${org_node}-tls-cert -o json \
      | jq -r .data.\"tls.crt\" \
      | base64 -d \
      > ${ORG_NODE_TLS_DIR}/tls-cert.pem

  pop_step
}

function deploy_org() {
  local org_name=$1
  local org_type=$2

  _load_org_config $org_name $org_type
  _launch_org_tls_cert_issuer $org_name

  _deploy_org_ca $org_name $org_type
  _enroll_root_ca_user $org_name $org_type

  _create_org_msp $org_name $org_type

  _enroll_node_admin $org_name $org_type "${org_type}0"

  _enroll_org_user $org_name $org_type ${org_name}-admin admin
  _enroll_org_user $org_name $org_type ${org_name}-user1 client

  _deploy_node $org_name $org_type "${org_type}0"
}

function destroy_org() {
  _stop_services
}

function _stop_services() {
  push_step "Stopping Fabric services"

  kubectl -n $CLUSTER_NAMESPACE delete ingress --all
  kubectl -n $CLUSTER_NAMESPACE delete deployment --all
  kubectl -n $CLUSTER_NAMESPACE delete pod --all
  kubectl -n $CLUSTER_NAMESPACE delete service --all
  kubectl -n $CLUSTER_NAMESPACE delete configmap --all
  kubectl -n $CLUSTER_NAMESPACE delete cert --all
  kubectl -n $CLUSTER_NAMESPACE delete issuer --all
  kubectl -n $CLUSTER_NAMESPACE delete secret --all
  kubectl -n $CLUSTER_NAMESPACE delete jobs --all

  pop_step
}