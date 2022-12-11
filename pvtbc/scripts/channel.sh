. utils.sh

function create_channel() {
    local channel_name=$1
    local orderer_org_name=$2

    export CHANNEL_NAME=$channel_name
    export ORDERER_ORG_NAME=$orderer_org_name

    kube_apply_template "$K8S_NETWORK_JOBS_PATH/create-channel-job.yaml" $CLUSTER_NAMESPACE
    kube_wait_until_job_completed "$K8S_NETWORK_JOBS_PATH/create-channel-job.yaml" $CLUSTER_NAMESPACE
}

function join_channel() {
    local channel_name=$1
    local joining_org_name=$2
    local orderer_org_name=$3

    # exports to replace in the template
    export CHANNEL_NAME=$channel_name
    export JOINING_ORG_NODE="peer0"
    export JOINING_ORG_NAME=$joining_org_name
    export ORDERER_ORG_NAME=$orderer_org_name

    kube_apply_template "$K8S_ORG_JOBS_PATH/peer-join-channel-job.yaml" $CLUSTER_NAMESPACE
    kube_wait_until_job_completed "$K8S_ORG_JOBS_PATH/peer-join-channel-job.yaml" $CLUSTER_NAMESPACE
}