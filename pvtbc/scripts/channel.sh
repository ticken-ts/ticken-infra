function create_channel() {
    local channel_name=$1
    local orderer_org_name=$2

    push_step "creating channel: $channel_name"

    export CHANNEL_NAME=$channel_name
    export ORDERER_ORG_NAME=$orderer_org_name

    kube_apply_template "$K8S_NETWORK_JOBS_PATH/create-channel-job.yaml" $CLUSTER_NAMESPACE
    kube_wait_until_job_completed "$K8S_NETWORK_JOBS_PATH/create-channel-job.yaml" $CLUSTER_NAMESPACE

    pop_step
}

function org_peers_join_channel() {
    local channel_name=$1
    local joining_org_name=$2
    local orderer_org_name=$3

    push_step "joining $joining_org_name peers to channel $channel_name"

    # exports to replace in the template
    export CHANNEL_NAME=$channel_name
    export JOINING_ORG_NODE="peer0"
    export JOINING_ORG_NAME=$joining_org_name
    export ORDERER_ORG_NAME=$orderer_org_name

    kube_apply_template "$K8S_ORG_JOBS_PATH/peer-join-channel-job.yaml" $CLUSTER_NAMESPACE
    kube_wait_until_job_completed "$K8S_ORG_JOBS_PATH/peer-join-channel-job.yaml" $CLUSTER_NAMESPACE

    pop_step
}

function org_join_channel() {
    local channel_name=$1
    local joining_org_name=$2
    local genesis_org_name=$3
    local orderer_org_name=$4

    push_step "joining org $joining_org_name to channel $channel_name"

    # exports to replace in the template
    export CHANNEL_NAME=$channel_name
    export JOINING_ORG_NAME=$joining_org_name
    export GENESIS_ORG_NAME=$genesis_org_name
    export ORDERER_ORG_NAME=$orderer_org_name

    kube_apply_template "$K8S_ORG_JOBS_PATH/org-join-channel-job.yaml" $CLUSTER_NAMESPACE
    kube_wait_until_job_completed "$K8S_ORG_JOBS_PATH/org-join-channel-job.yaml" $CLUSTER_NAMESPACE

    pop_step
}