. utils.sh

CONTAINER_CLI="docker"

function deploy_chaincode() {
    local org_name=$1
    local org_domain=$2
    local channel_name=$3

    local cc_name=$4
    local cc_path=$5
    local cc_label=$4

    local orderer_org_name=6
    local orderer_org_domain=$7

    local k8s_namespace=$8

    local cc_folder=$(get_folder_full_path $cc_path)
    local cc_package="/tmp/ticken-pv/chaincodes/${org_name}/${cc_name}.tgz"

    prepare_chaincode_image ${cc_folder} ${cc_name}
    package_ccaas_chaincode ${cc_name} ${cc_label} ${cc_package}

    set_chaincode_id      ${cc_package}
    launch_chaincode      ${org_name} ${cc_name} ${CHAINCODE_ID} ${CHAINCODE_IMAGE} ${k8s_namespace}

    activate_chaincode    ${org_name} "peer0" ${org_domain} ${channel_name} ${CHAINCODE_ID} ${cc_name} ${orderer_org_name} ${orderer_org_domain}
}

# Prepare a chaincode image for use in a builder package.
# Sets the CHAINCODE_IMAGE environment variable
function prepare_chaincode_image() {
  local cc_folder=$1
  local cc_name=$2

  build_chaincode_image ${cc_folder} ${cc_name}

  export CHAINCODE_IMAGE=localhost:${LOCAL_REGISTRY_PORT}/${cc_name}
  publish_chaincode_image ${cc_name} ${CHAINCODE_IMAGE}
}

function build_chaincode_image() {
  local cc_folder=$1
  local cc_name=$2

  echo "$cc_folder"

  #push_fn "Building chaincode image ${cc_name}"
  $CONTAINER_CLI build -t ${cc_name} ${cc_folder}
  #pop_fn
}

# tag a docker image with a new name and publish to a remote container registry
function publish_chaincode_image() {
  local cc_name=$1
  local cc_url=$2
  #push_fn "Publishing chaincode image ${cc_url}"
  ${CONTAINER_CLI} tag  ${cc_name} ${cc_url}
  ${CONTAINER_CLI} push ${cc_url}
  #pop_fn
}

function package_ccaas_chaincode() {
  local cc_name=$1
  local cc_label=$2
  local cc_archive=$3

  local cc_folder=$(dirname $cc_archive)
  local archive_name=$(basename $cc_archive)

  #push_fn "Packaging ccaas chaincode ${cc_label}"

  mkdir -p ${cc_folder}
  chmod -R 777 ${cc_folder}

  # Allow the user to override the service URL for the endpoint. This allows, for instance,
  # local debugging at the 'host.docker.internal' DNS alias.
  local cc_default_address="{{.peername}}-ccaas-${cc_name}:9999"
  local cc_address=${TEST_NETWORK_CHAINCODE_ADDRESS:-$cc_default_address}

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

  #pop_fn
}

function set_chaincode_id() {
  local cc_package=$1

  cc_sha256=$(shasum -a 256 ${cc_package} | tr -s ' ' | cut -d ' ' -f 1)
  cc_label=$(tar zxfO ${cc_package} metadata.json | jq -r '.label')

  CHAINCODE_ID=${cc_label}:${cc_sha256}
}

function launch_chaincode_service() {
  local org=$1
  local peer=$2
  local cc_name=$3
  local cc_id=$4
  local cc_image=$5
  local k8s_namespace=$6

  #push_fn "Launching chaincode container \"${cc_image}\""

  # The chaincode endpoint needs to have the generated chaincode ID available in the environment.
  # This could be from a config map, a secret, or by directly editing the deployment spec.  Here we'll keep
  # things simple by using sed to substitute script variables into a yaml template.

  #  cat kube/${org}/${org}-cc-template.yaml \
  #    | sed 's,{{CHAINCODE_NAME}},'${cc_name}',g' \
  #    | sed 's,{{CHAINCODE_ID}},'${cc_id}',g' \
  #    | sed 's,{{CHAINCODE_IMAGE}},'${cc_image}',g' \
  #    | sed 's,{{PEER_NAME}},'${peer}',g' \
  #    | exec kubectl -n $ORG1_NS apply -f -

  #kubectl -n $ORG1_NS rollout status deploy/${org}${peer}-ccaas-${cc_name}

  export ORG_NAME=$org
  export CHAINCODE_ID=$cc_id
  export CHAINCODE_NAME=$cc_name
  export CHAINCODE_IMAGE=$cc_image

  kube_apply_template "$CHAINCODE_TEMPLATE_PATH/cc.yaml" $k8s_namespace
  kube_apply_template "$CHAINCODE_TEMPLATE_PATH/cc-service.yaml" $k8s_namespace
  kube_wait_until_pod_running "$CHAINCODE_TEMPLATE_PATH/cc.yaml" $k8s_namespace

  #pop_fn
}

function launch_chaincode() {
  local org=$1
  local cc_name=$2
  local cc_id=$3
  local cc_image=$4
  local k8s_namespace=$5

  launch_chaincode_service ${org} peer0 ${cc_name} ${cc_id} ${cc_image} ${k8s_namespace}
}

function activate_chaincode() {
  export ORG_NAME=$1
  export ORG_NODE=$2
  export ORG_DOMAIN=$3
  export CHANNEL_NAME=$4

  export CHAINCODE_ID=$5
  export CHAINCODE_NAME=$6

  export ORDERER_ORG_NAME=$7
  export ORDERER_ORG_DOMAIN=$8

  kube_apply_template "$ORG_JOBS_TEMPLATES_PATH/activate-chaincode-job.yaml" $k8s_namespace
  kube_wait_until_job_completed "$ORG_JOBS_TEMPLATES_PATH/activate-chaincode-job.yaml" $k8s_namespace
}