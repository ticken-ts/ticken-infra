function _pull_docker_images() {
  $CONTAINER_CLI pull ${FABRIC_CA_TOOLS_IMAGE}
  $CONTAINER_CLI pull ${FABRIC_ORDERER_IMAGE}
  $CONTAINER_CLI pull ${FABRIC_TOOLS_IMAGE}
  $CONTAINER_CLI pull ${FABRIC_PEER_IMAGE}
  $CONTAINER_CLI pull ${FABRIC_CA_IMAGE}
  $CONTAINER_CLI pull ${COUCHDB_IMAGE}
}

function _kind_load_docker_images() {
  kind load docker-image ${FABRIC_CA_TOOLS_IMAGE} --name $CLUSTER_NAME
  kind load docker-image ${FABRIC_ORDERER_IMAGE}  --name $CLUSTER_NAME
  kind load docker-image ${FABRIC_TOOLS_IMAGE}    --name $CLUSTER_NAME
  kind load docker-image ${FABRIC_PEER_IMAGE}     --name $CLUSTER_NAME
  kind load docker-image ${FABRIC_CA_IMAGE}       --name $CLUSTER_NAME
  kind load docker-image ${COUCHDB_IMAGE}         --name $CLUSTER_NAME
}

function _copy_artifacts_to_volume() {
  rm -r $CLUSTER_VOLUME_PATH
  mkdir -p $CLUSTER_VOLUME_PATH

  cp -r "../k8s-artifacts/scripts"            "$CLUSTER_VOLUME_PATH/scripts"
  cp -r "../k8s-artifacts/configtx"           "$CLUSTER_VOLUME_PATH/configtx"
  cp -r "../k8s-artifacts/connection-profile" "$CLUSTER_VOLUME_PATH/connection-profile"

  chmod -R 777 $CLUSTER_VOLUME_PATH
}

function _init_cluster_volumes() {
  kubectl create namespace $CLUSTER_NAMESPACE
  kubectl apply -n $CLUSTER_NAMESPACE -f "$K8S_CLUSTER_FILES_PATH/common-pvc.yaml"
  kubectl apply -n $CLUSTER_NAMESPACE -f "$K8S_CLUSTER_FILES_PATH/cluster-pv.yaml"
}

function _kind_init() {
  kind create cluster --name $CLUSTER_NAME --config "$K8S_CLUSTER_FILES_PATH/kind-cluster.yaml"
}

function _kind_launch_docker_registry() {
  # create registry container unless it already exists
  local reg_name=${LOCAL_REGISTRY_NAME}
  local reg_port=${LOCAL_REGISTRY_PORT}
  local reg_interface=${LOCAL_REGISTRY_INTERFACE}

  running="$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)"
  if [ "${running}" != 'true' ]; then
    docker run  \
      --detach  \
      --restart always \
      --name    "${reg_name}" \
      --publish "${reg_interface}:${reg_port}:5000" \
      registry:2
  fi

  # connect the registry to the cluster network
  # (the network may already be connected)
  docker network connect "kind" "${reg_name}" || true

  # Document the local registry
  # https://github.com/kubernetes/enhancements/tree/master/keps/sig-cluster-lifecycle/generic/1755-communicating-a-local-registry
  cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${reg_port}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF
}



function ticken_cluster_init() {
  _kind_init
  _kind_launch_docker_registry
  _pull_docker_images
  _kind_load_docker_images
  _copy_artifacts_to_volume
  _init_cluster_volumes
}