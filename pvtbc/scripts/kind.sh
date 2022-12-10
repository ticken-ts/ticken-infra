function kind_load_docker_images() {
  kind load docker-image hyperledger/fabric-ca1:.4.9
  kind load docker-image hyperledger/fabric-orderer:2.3
  kind load docker-image hyperledger/fabric-peer:2.3
  kind load docker-image couchdb:3.2.2
}

function launch_docker_registry() {
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

function stop_docker_registry() {
  push_fn "Deleting container registry \"${LOCAL_REGISTRY_NAME}\" at localhost:${LOCAL_REGISTRY_PORT}"

  docker kill kind-registry || true
  docker rm kind-registry   || true

  pop_fn
}

function kind_delete() {
  push_fn "Deleting KIND cluster ${CLUSTER_NAME}"

  kind delete cluster --name $CLUSTER_NAME

  pop_fn
}

function kind_init() {
  kind create cluster --name ticken-pvtbc-network --config "$CLUSTER_K8S/kind-cluster.yaml"
  launch_docker_registry
}

function kind_unkind() {
  kind_delete
  stop_docker_registry
}