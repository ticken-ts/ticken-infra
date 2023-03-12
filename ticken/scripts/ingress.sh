function deploy_app_load_balancer() {
  local app=$1
  push_step "$app - deploying ingress"
  kube_apply_template "$K8S_INGRESSES_PATH/${app}.yaml" $CLUSTER_NAMESPACE
  pop_step
}