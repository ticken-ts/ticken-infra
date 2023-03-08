function deploy_keycloak() {
  _deploy_dependency $KEYCLOAK_DEP_NAME
  sleep 10 # wait 5 seconds until keycloak is ready
  _bootstrap_keycloak
}

function deploy_rabbitmq() {
  _deploy_dependency $RABBITMQ_DEP_NAME
}

function deploy_ganache() {
  _deploy_dependency $GANACHE_DEP_NAME
}

function _deploy_dependency() {
  local dependency_name=$1

  kube_apply_template "$K8S_DEPS_PATH/${dependency_name}.yaml" $CLUSTER_NAMESPACE
  kubectl -n $CLUSTER_NAMESPACE rollout status deploy/"${dependency_name}"
}

function _bootstrap_keycloak() {
  local keycloak_terraform_def="../../keycloak"

  rm -f "${keycloak_terraform_def}/terraform.tfstate"

  terraform -chdir=${keycloak_terraform_def} init

  # todo -> move to env variables or secrets
  local keycloak_admin_username="admin"
  local keycloak_admin_password="admin"

  terraform -chdir=${keycloak_terraform_def} apply \
    -var "keycloak_url=http://ticken.auth.com:8080" \
    -var "keycloak_admin_username=${keycloak_admin_username}" \
    -var "keycloak_admin_password=${keycloak_admin_password}" \
    -auto-approve
}
