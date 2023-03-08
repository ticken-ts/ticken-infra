. const.sh
. deps.sh
. logs.sh
. utils.sh
. cluster.sh
. service.sh

# enables the "errexit" option, which causes the shell to exit
# immediately if a command exits with a non-zero exit status.
set -o errexit

# Initialize the logging system - control output to 'network.log'
# and everything else to 'network-debug.log'
logging_init

function bootstrap() {
#  log_op "Starting cluster"
#  ticken_cluster_init
#  log_op "Cluster running \n"

#  log_op "Deploying Keycloak"
#  deploy_keycloak
#  log_op "Keycloak deployed \n"

  log_op "Deploying RabbitMQ"
  deploy_rabbitmq
  log_op "RabbitMQ deployed \n"

  log_op "Deploying ganache"
  deploy_ganache
  log_op "Ganache deployed \n"

  log_op "Deploying $TICKEN_EVENT_SERVICE_NAME"
  deploy_service $TICKEN_EVENT_SERVICE_NAME $TICKEN_EVENT_SERVICE_PATH
  log_op "Service deployed \n"

  log_op "Deploying $TICKEN_TICKET_SERVICE_NAME"
  deploy_service $TICKEN_TICKET_SERVICE_NAME $TICKEN_TICKET_SERVICE_PATH
  log_op "Service deployed \n"

  log_op "Deploying $TICKEN_VALIDATOR_SERVICE_NAME"
  deploy_service $TICKEN_VALIDATOR_SERVICE_NAME $TICKEN_VALIDATOR_SERVICE_PATH
  log_op "Service deployed \n"
}

function armaggedon() {
  log_op "stopping cluster"
  ticken_cluster_delete
  log_op "cluster stopped \n"
}

MODE=$1

if [ "${MODE}" == "bootstrap" ]; then
  log_title "⛓️ - Bootstrapping Ticken - ⛓ "
  bootstrap
  log_title "🏁 - Ticken running - 🏁 "
fi

if [ "${MODE}" == "armaggedon" ]; then
  log_title "🔥 - Destroying Ticken - 🔥 "
  armaggedon
  log_title "🏁 - Ticken destroyed - 🏁 "
fi