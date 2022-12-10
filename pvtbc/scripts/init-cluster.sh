. kind.sh
. cluster.sh
. utils.sh

export K8S_NAMESPACE=$1

readonly CLUSTER_K8S="../k8s/cluster"
readonly VOL_MOUNT_PATH="/tmp/ticken-pv"

context LOCAL_REGISTRY_NAME           kind-registry
context LOCAL_REGISTRY_INTERFACE      127.0.0.1
context LOCAL_REGISTRY_PORT           5000

function copy_artifacts_to_pv() {
  rm -r "/tmp/ticken-pv"
  mkdir -p "/tmp/ticken-pv"

  cp -r "../k8s-artifacts/scripts" "$VOL_MOUNT_PATH/scripts"
  cp -r "../k8s-artifacts/configtx" "$VOL_MOUNT_PATH/configtx"
  cp -r "../k8s-artifacts/connection-profile" "$VOL_MOUNT_PATH/connection-profile"

  chmod -R 777 /tmp/ticken-pv
}

function create_volumes() {
  kubectl create namespace $K8S_NAMESPACE
  kubectl apply -n $K8S_NAMESPACE -f "$CLUSTER_K8S/common-pvc.yaml"
  kubectl apply -n $K8S_NAMESPACE -f "$CLUSTER_K8S/cluster-pv.yaml"
}

function init_cluster() {
  copy_artifacts_to_pv
  kind_init
  cluster init
  create_volumes
}

init_cluster

