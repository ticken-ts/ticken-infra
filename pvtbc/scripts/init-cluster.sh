. utils.sh

export NS=$1
context CLUSTER_K8S "../k8s/cluster"

function copy_artifacts_to_pv() {
  rm -r "/tmp/ticken-pv"
  mkdir -p "/tmp/ticken-pv"
  cp -r "../k8s-artifacts/scripts" "/tmp/ticken-pv/scripts"
  cp -r "../k8s-artifacts/configtx" "/tmp/ticken-pv/configtx"
  cp -r "../k8s-artifacts/connection-profile" "/tmp/ticken-pv/connection-profile"
  chmod -R 777 /tmp/ticken-pv
}

function create_volumes() {
  kubectl create namespace $NS
  kubectl apply -n $NS -f "$CLUSTER_K8S/common-pvc.yaml"
  kubectl apply -n $NS -f "$CLUSTER_K8S/cluster-pv.yaml"
}

function kind_init() {
  kind create cluster --name ticken-pvtbc-network --config "$CLUSTER_K8S/kind-cluster.yaml"
}

function init_cluster() {
  copy_artifacts_to_pv
  kind_init
  create_volumes
}

init_cluster

