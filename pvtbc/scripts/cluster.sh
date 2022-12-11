function _pull_docker_images() {
  $CONTAINER_CLI pull ${FABRIC_CA_TOOLS_IMAGE}
  $CONTAINER_CLI pull ${FABRIC_ORDERER_IMAGE}
  $CONTAINER_CLI pull ${CCAAS_BUILDER_IMAGE}
  $CONTAINER_CLI pull ${FABRIC_TOOLS_IMAGE}
  $CONTAINER_CLI pull ${FABRIC_PEER_IMAGE}
  $CONTAINER_CLI pull ${FABRIC_CA_IMAGE}
  $CONTAINER_CLI pull ${COUCHDB_IMAGE}
}

function _kind_load_docker_images() {
  kind load docker-image ${FABRIC_CA_TOOLS_IMAGE} --name $CLUSTER_NAME
  kind load docker-image ${FABRIC_ORDERER_IMAGE}  --name $CLUSTER_NAME
  kind load docker-image ${CCAAS_BUILDER_IMAGE}   --name $CLUSTER_NAME
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
  cp -r "../k8s-artifacts/org-config"         "$CLUSTER_VOLUME_PATH/org-config"
  cp -r "../k8s-artifacts/connection-profile" "$CLUSTER_VOLUME_PATH/connection-profile"

  chmod -R 777 $CLUSTER_VOLUME_PATH
}

function _init_cluster_volumes() {
  kubectl create namespace $CLUSTER_NAMESPACE
  kubectl apply -n $CLUSTER_NAMESPACE -f "$K8S_CLUSTER_FILES_PATH/common-pvc.yaml"
  kubectl apply -n $CLUSTER_NAMESPACE -f "$K8S_CLUSTER_FILES_PATH/cluster-pv.yaml"
}

function _kind_init() {
  local reg_name=${LOCAL_REGISTRY_NAME}
  local reg_port=${LOCAL_REGISTRY_PORT}

  local ingress_http_port=${NGINX_HTTP_PORT}
  local ingress_https_port=${NGINX_HTTPS_PORT}

  cat <<EOF | kind create cluster --name $CLUSTER_NAME --config=-
---
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"

    extraMounts:
      - hostPath: /tmp/ticken-pv
        containerPath: /ticken-pv

    extraPortMappings:
      - containerPort: 80
        hostPort: ${ingress_http_port}
        protocol: TCP

      - containerPort: 443
        hostPort: ${ingress_https_port}
        protocol: TCP

# create a cluster with the local registry enabled in containerd
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${reg_port}"]
    endpoint = ["http://${reg_name}:${reg_port}"]

EOF

  # connect the registry to the cluster network
  # (the network may already be connected)
  docker network connect "kind" "${reg_name}" || true

  for node in $(kind get nodes --name $CLUSTER_NAME); do
    kubectl annotate node "${node}" "kind.x-k8s.io/registry=localhost:${reg_port}";

    # workaround for https://github.com/hyperledger/fabric-samples/issues/550 -
    # pods can not resolve external DNS
    docker exec "$node" sysctl net.ipv4.conf.all.route_localnet=1;
  done

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

function _launch_docker_registry() {
  # create registry container unless it already exists
  local reg_name=${LOCAL_REGISTRY_NAME}
  local reg_port=${LOCAL_REGISTRY_PORT}
  local reg_interface=${LOCAL_REGISTRY_INTERFACE}
  local reg_storage_path=${LOCAL_REGITRY_STORAGE}

  running="$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)"
  if [ "${running}" != 'true' ]; then
    docker run  \
      --detach  \
      --restart always \
      --name "${reg_name}" \
      -v ${reg_storage_path}:/var/lib/regis \
      --publish "${reg_interface}:${reg_port}:5000" \
      registry:2
  fi
}

function ticken_cluster_init() {
  _launch_docker_registry
  _kind_init
  _pull_docker_images
  _kind_load_docker_images
  _copy_artifacts_to_volume
  _init_cluster_volumes
}