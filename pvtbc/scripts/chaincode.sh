function deploy_new_chaincode() {
    local channel_name=$1
    local org_name=$2
    local orderer_org_name=$3

    local cc_name=$4
    local cc_path=$(get_folder_full_path $5)

    _prepare_chaincode_image ${cc_path} ${cc_name}
    install_chaincode  ${channel_name} ${org_name} ${orderer_org_name} ${cc_name}
    _activate_chaincode ${channel_name} ${org_name} "peer0" ${orderer_org_name} ${CHAINCODE_ID} ${cc_name}
}

function install_chaincode() {
  local channel_name=$1
  local org_name=$2
  local orderer_org_name=$3
  local cc_name=$4

  local cc_image_url="localhost:${LOCAL_REGISTRY_PORT}/${cc_name}"
  local cc_package_path="$CLUSTER_VOLUME_PATH/chaincodes/${org_name}/${cc_name}.tgz"

  _package_ccaas_chaincode ${cc_name} ${cc_package_path} ${org_name}

  _set_chaincode_id ${cc_package_path}
  _launch_chaincode_service ${org_name} ${cc_name} ${CHAINCODE_ID} ${cc_image_url}

  _install_chaincode ${channel_name} ${org_name} "peer0" ${orderer_org_name} ${CHAINCODE_ID} ${cc_name}
}

# Prepare a chaincode image for use in a builder package.
# Sets the CHAINCODE_IMAGE environment variable
function _prepare_chaincode_image() {
  local cc_folder=$1
  local cc_name=$2
  local cc_url="localhost:${LOCAL_REGISTRY_PORT}/${cc_name}"

  __build_chaincode_image $cc_folder $cc_name
  __publish_chaincode_image $cc_url $cc_name
}

function __build_chaincode_image() {
    local cc_folder=$1
    local cc_name=$2

    push_step "building chaincode $cc_name image"

    # build chaincode image
    ${CONTAINERS_CLI} build -t ${cc_name} ${cc_folder}

    pop_step
}

function __publish_chaincode_image() {
      local cc_url=$1
      local cc_name=$2

      push_step "publishing chaincode $cc_name image to $cc_url"

      # push chaincode image
      ${CONTAINERS_CLI} tag  ${cc_name} ${cc_url}
      ${CONTAINERS_CLI} push ${cc_url}

      pop_step
}


function _package_ccaas_chaincode() {
  local cc_name=$1
  local cc_archive=$2
  local org_name=$3
  local cc_label=$cc_name

  local cc_folder=$(dirname $cc_archive)
  local archive_name=$(basename $cc_archive)

  push_step "packaging ccaas chaincode ${cc_label}"

  mkdir -p ${cc_folder} && chmod -R 777 ${cc_folder}

  local cc_address="${org_name}-${cc_name}:9999"

  cat << EOF > ${cc_folder}/connection.json
{
  "address": "${cc_address}",
  "dial_timeout": "10s",
  "tls_required": false
}
EOF

  cat << EOF > ${cc_folder}/metadata.json
{
  "type": "ccaas",
  "label": "${cc_label}"
}
EOF

  tar -C ${cc_folder} -zcf ${cc_folder}/code.tar.gz connection.json
  tar -C ${cc_folder} -zcf ${cc_archive} code.tar.gz metadata.json

  rm ${cc_folder}/code.tar.gz

  pop_step
}

function _set_chaincode_id() {
  local cc_package=$1

  push_step "setting chaincode id"

  cc_sha256=$(shasum -a 256 ${cc_package} | tr -s ' ' | cut -d ' ' -f 1)
  cc_label=$(tar zxfO ${cc_package} metadata.json | jq -r '.label')

  CHAINCODE_ID=${cc_label}:${cc_sha256}

  pop_step
}

function _launch_chaincode_service() {
  local org=$1
  local cc_name=$2
  local cc_id=$3
  local cc_image=$4

  push_step "launching chaincode $cc_name service"

  local peer=peer0

  export ORG_NAME=$org
  export CHAINCODE_ID=$cc_id
  export CHAINCODE_NAME=$cc_name
  export CHAINCODE_IMAGE=$cc_image

  kube_apply_template "$K8S_CHAINCODE_PATH/cc.yaml" $CLUSTER_NAMESPACE
  kube_apply_template "$K8S_CHAINCODE_PATH/cc-service.yaml" $CLUSTER_NAMESPACE
  kubectl -n $CLUSTER_NAMESPACE rollout status deploy/${org}-${cc_name}

  pop_step
}

function _install_chaincode() {
  export CHANNEL_NAME=$1

  export ORG_NAME=$2
  export ORG_NODE=$3
  export ORDERER_ORG_NAME=$4

  export CHAINCODE_ID=$5
  export CHAINCODE_NAME=$6

  push_step "installing chaincode in peer $ORG_NODE"

  kube_apply_template "$K8S_ORG_JOBS_PATH/install-chaincode-job.yaml" $CLUSTER_NAMESPACE
  kube_wait_until_job_completed "$K8S_ORG_JOBS_PATH/install-chaincode-job.yaml" $CLUSTER_NAMESPACE

  pop_step
}

function _activate_chaincode() {
  export CHANNEL_NAME=$1

  export ORG_NAME=$2
  export ORG_NODE=$3
  export ORDERER_ORG_NAME=$4

  export CHAINCODE_ID=$5
  export CHAINCODE_NAME=$6

  push_step "activating chaincode $cc_name"

  kube_apply_template "$K8S_ORG_JOBS_PATH/activate-chaincode-job.yaml" $CLUSTER_NAMESPACE
  kube_wait_until_job_completed "$K8S_ORG_JOBS_PATH/activate-chaincode-job.yaml" $CLUSTER_NAMESPACE

  pop_step
}