function _launch_docker_registry() {
  push_step "launching docker registry"

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

  pop_step
}

function _stop_docker_registry() {
  docker kill kind-registry || true
  docker rm kind-registry   || true
}

function _kind_init() {
  push_step "initializing kind cluster"

  # prevent the next kind cluster from using the previous Fabric network's enrollments.
  rm -rf ${CLUSTER_VOLUME_PATH}
  kind delete cluster --name $CLUSTER_NAME
  mkdir -p $CLUSTER_VOLUME_PATH

  local host_volume_path=${CLUSTER_VOLUME_PATH}

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
      - hostPath: ${host_volume_path}
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

  pop_step
}

function _kind_delete() {
  kind delete cluster --name $CLUSTER_NAME
}


function _apply_nginx_ingress() {
  push_step "applying nginx ingress"

  # 1.1.2 static ingress with modifications to enable ssl-passthrough
  # k3s : 'cloud'
  # kind : 'kind'
  # kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.2/deploy/static/provider/cloud/deploy.yaml

  kubectl apply -f "$K8S_CLUSTER_FILES_PATH/ingress-nginx-kind.yaml"

  # wait for nginx
  #kubectl wait --namespace ingress-nginx \
  #  --for=condition=ready pod \
  #  --selector=app.kubernetes.io/component=controller \
  #  --timeout=2m

  pop_step
}

function _apply_cert_manager() {
  push_step "applying cert manager"

  # Install cert-manager to manage TLS certificates
  kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.yaml

  kubectl -n cert-manager rollout status deploy/cert-manager
  kubectl -n cert-manager rollout status deploy/cert-manager-cainjector
  kubectl -n cert-manager rollout status deploy/cert-manager-webhook

  pop_step
}

function _kind_load_docker_images() {
  push_step "loading docker images"

  pull_image_if_not_present ${FABRIC_CCAAS_BUILDER_IMAGE}
  pull_image_if_not_present ${FABRIC_CA_TOOLS_IMAGE}
  pull_image_if_not_present ${FABRIC_ORDERER_IMAGE}
  pull_image_if_not_present ${FABRIC_TOOLS_IMAGE}
  pull_image_if_not_present ${FABRIC_PEER_IMAGE}
  pull_image_if_not_present ${FABRIC_CA_IMAGE}
  pull_image_if_not_present ${COUCHDB_IMAGE}

  kind load docker-image ${FABRIC_CCAAS_BUILDER_IMAGE} --name $CLUSTER_NAME
  kind load docker-image ${FABRIC_CA_TOOLS_IMAGE}      --name $CLUSTER_NAME
  kind load docker-image ${FABRIC_ORDERER_IMAGE}       --name $CLUSTER_NAME
  kind load docker-image ${FABRIC_TOOLS_IMAGE}         --name $CLUSTER_NAME
  kind load docker-image ${FABRIC_PEER_IMAGE}          --name $CLUSTER_NAME
  kind load docker-image ${FABRIC_CA_IMAGE}            --name $CLUSTER_NAME
  kind load docker-image ${COUCHDB_IMAGE}              --name $CLUSTER_NAME

  pop_step
}

function _copy_artifacts_to_volume() {
  push_step "copying artifact to cluster volume"

  cp -r "../k8s-artifacts/scripts"            "$CLUSTER_VOLUME_PATH/scripts"
  cp -r "../k8s-artifacts/configtx"           "$CLUSTER_VOLUME_PATH/configtx"
  cp -r "../k8s-artifacts/connection-profile" "$CLUSTER_VOLUME_PATH/connection-profile"

  chmod -R 777 $CLUSTER_VOLUME_PATH

  pop_step
}

function _init_cluster_volumes() {
  push_step "initializing cluster volume"

  kubectl create namespace $CLUSTER_NAMESPACE
  kubectl apply -n $CLUSTER_NAMESPACE -f "$K8S_CLUSTER_FILES_PATH/common-pvc.yaml"
  kubectl apply -n $CLUSTER_NAMESPACE -f "$K8S_CLUSTER_FILES_PATH/cluster-pv.yaml"

  pop_step
}

function _launch_root_CA() {
  push_step "launching root CA"

  kubectl -n $CLUSTER_NAMESPACE apply -f $K8S_CLUSTER_FILES_PATH/root-tls-cert-issuer.yaml
  kubectl -n $CLUSTER_NAMESPACE wait --timeout=30s --for=condition=Ready issuer/root-tls-cert-issuer

  pop_step
}


function ticken_cluster_init() {
  _launch_docker_registry

  _kind_init

  _apply_nginx_ingress
  _apply_cert_manager

  _kind_load_docker_images

  _copy_artifacts_to_volume
  _init_cluster_volumes

  _launch_root_CA
}

function ticken_cluster_delete() {
  _kind_delete
  _stop_docker_registry
}
