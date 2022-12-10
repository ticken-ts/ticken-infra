#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# cluster "group" commands.  Like "main" for the fabric-cli "cluster" sub-command
function cluster_command_group() {

  # Default COMMAND is 'init' if not specified
  if [ "$#" -eq 0 ]; then
    COMMAND="init"

  else
    COMMAND=$1
    shift
  fi

  if [ "${COMMAND}" == "init" ]; then
    log "Initializing K8s cluster"
    cluster_init
    log "🏁 - Cluster is ready"

  elif [ "${COMMAND}" == "clean" ]; then
    log "Cleaning k8s cluster"
    cluster_clean
    log "🏁 - Cluster is cleaned"

  elif [ "${COMMAND}" == "load-images" ]; then
    log "Loading Docker images"
    load_images
    log "🏁 - Images are loaded"

  else
    print_help
    exit 1
  fi
}

function pull_docker_images() {
  push_fn "Pulling docker images for Fabric ${FABRIC_VERSION}"

  $CONTAINER_CLI pull ${CONTAINER_NAMESPACE} ${FABRIC_CONTAINER_REGISTRY}/fabric-ca:$FABRIC_CA_VERSION
  $CONTAINER_CLI pull ${CONTAINER_NAMESPACE} ${FABRIC_CONTAINER_REGISTRY}/fabric-orderer:$FABRIC_VERSION
  $CONTAINER_CLI pull ${CONTAINER_NAMESPACE} ${FABRIC_PEER_IMAGE}
  $CONTAINER_CLI pull ${CONTAINER_NAMESPACE} couchdb:3.2.2

  pop_fn
}

function cluster_init() {
  pull_docker_images
  kind_load_docker_images
}

function load_images() {
  if [ "${CLUSTER_RUNTIME}" == "kind" ]; then
    kind_load_docker_images
  fi
}