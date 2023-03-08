function deploy_service() {
  local service_name=$1
  local service_path=$2

  _prepare_service_image $service_name $service_path

  local service_image_url="localhost:${LOCAL_REGISTRY_PORT}/${service_name}"

  export SERVICE_IMAGE=$service_image_url

  _load_service_config $service_name
  _deploy_service_database $service_name
  _deploy_service_application $service_name
}

function _prepare_service_image() {
  local service_name=$1
  local service_path=$(get_folder_full_path $2)
  local service_image_url="localhost:${LOCAL_REGISTRY_PORT}/${service_name}"

  __build_service_image $service_path $service_name
  __publish_service_image $service_image_url $service_name
}

function __build_service_image() {
  local service_folder=$1
  local service_name=$2

  push_step "building service $service_name image"

  # build chaincode image
  ${CONTAINERS_CLI} build -t ${service_name} ${service_folder}

  pop_step
}

function __publish_service_image() {
  local service_image_url=$1
  local service_name=$2

  push_step "publishing service $service_name image to $service_image_url"

  # push chaincode image
  ${CONTAINERS_CLI} tag ${service_name} ${service_image_url}
  ${CONTAINERS_CLI} push ${service_image_url}

  pop_step
}

function _load_service_config() {
  local service_name=$1

  push_step "$service_name - loading config"

  local service_config_file=${K8S_SERVICE_PATH}/${service_name}/config.json
  kubectl -n $CLUSTER_NAMESPACE delete configmap ${service_name}-config || true
  kubectl -n $CLUSTER_NAMESPACE create configmap ${service_name}-config --from-file=${service_config_file}

  pop_step
}

function _deploy_service_database() {
  local service_name=$1

  push_step "$service_name - deploying database"

  kube_apply_template "$K8S_SERVICE_PATH/${service_name}/mongodb.yaml" $CLUSTER_NAMESPACE
  kubectl -n $CLUSTER_NAMESPACE rollout status deploy/"${service_name}-mongodb"

  pop_step
}

function _deploy_service_application() {
  local service_name=$1

  push_step "$service_name - deploying application"

  kube_apply_template "$K8S_SERVICE_PATH/${service_name}/app.yaml" $CLUSTER_NAMESPACE
  kubectl -n $CLUSTER_NAMESPACE rollout status deploy/"${service_name}"

  pop_step
}
