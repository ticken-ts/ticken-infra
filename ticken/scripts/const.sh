# Set an environment variable based on an optional override (TICKEN_NETWORK_{name})
# from the calling shell.  If the override is not available, assign the parameter
# to a default value.
function context() {
  local name=$1
  local default_value=$2
  local override_name=TICKEN_NETWORK_${name}

  export ${name}="${!override_name:-${default_value}}"
}

#--------------------------- TICKEN  -----------------------------#
context DOMAIN "localho.st"

context GANACHE_DEP_NAME  "ganache"
context RABBITMQ_DEP_NAME "rabbitmq"
context KEYCLOAK_DEP_NAME "keycloak"

context TICKEN_EVENT_SERVICE_NAME  "ticken-event-service"
context TICKEN_EVENT_SERVICE_PATH  "../../../ticken-event-service"

context TICKEN_TICKET_SERVICE_NAME  "ticken-ticket-service"
context TICKEN_TICKET_SERVICE_PATH  "../../../ticken-ticket-service"

context TICKEN_VALIDATOR_SERVICE_NAME  "ticken-validator-service"
context TICKEN_VALIDATOR_SERVICE_PATH  "../../../ticken-validator-service"

context ATTENDANTS_APP "attendants-app"
context ORGANIZERS_APP "organizers-app"
context VALIDATORS_APP "validators-app"
#-----------------------------------------------------------------#


#--------------------------- LOGS --------------------------------#
context BASE_LOGS_PATH  "../logs"
context LOG_FILE        "${BASE_LOGS_PATH}/ticken.log"
context DEBUG_FILE      "${BASE_LOGS_PATH}/ticken-debug.log"
context LOG_ERROR_LINES 2
#-----------------------------------------------------------------#


#-------------------------- K8S PATH -----------------------------#
context K8S_BASE_PATH  "../k8s"
context K8S_CLUSTER_FILES_PATH  "$K8S_BASE_PATH/cluster"
context K8S_SERVICE_PATH        "$K8S_BASE_PATH/services"
context K8S_DEPS_PATH           "$K8S_BASE_PATH/deps"
context K8S_INGRESSES_PATH      "$K8S_BASE_PATH/ingresses"

context K8S_ARTIFACTS_PATH      "../artifacts"
#-----------------------------------------------------------------#


#--------------------------- CLUSTER -----------------------------#
context CLUSTER_VOLUME_PATH "/tmp/ticken/ticken-pv"
context CLUSTER_NAMESPACE   "ticken"
context CLUSTER_NAME        "ticken"
context NGINX_HTTP_PORT     8080
context NGINX_HTTPS_PORT    8443
#-----------------------------------------------------------------#


#------------------------- CONTAINERS ----------------------------#
context CONTAINERS_CLI           "docker"
context LOCAL_REGISTRY_NAME      ticken-docker-registry
context LOCAL_REGISTRY_INTERFACE 127.0.0.1
context LOCAL_REGISTRY_PORT      5000
context LOCAL_REGITRY_STORAGE    "/tmp/ticken/registry"
#-----------------------------------------------------------------#


#--------------------------- IMAGES ------------------------------#
context MONGODB_IMAGE  "mongo:6.0.4"
context RABBITMQ_IMAGE "rabbitmq:3-management"
context KEYCLOAK_IMAGE "quay.io/keycloak/keycloak:latest"
context GANACHE_IMAGE  "trufflesuite/ganache-cli:latest"
#-----------------------------------------------------------------#

#----------------------------- DEV -------------------------------#
context TICKEN_EVENT_SERVICE_DB_LOCAL_PORT     "30000"
context TICKEN_TICKET_SERVICE_DB_LOCAL_PORT    "30001"
context TICKEN_VALIDATOR_SERVICE_DB_LOCAL_PORT "30002"
#-----------------------------------------------------------------#