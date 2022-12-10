. utils.sh

function create_channel() {
    local channel_name=$1
    local orderer_org_name=$2
    local orderer_org_domain=$3
    local k8s_namespace=$4

    # exports to replace in the template
    export CHANNEL_NAME=$channel_name
    export ORDERER_ORG_NAME=$orderer_org_name
    export ORDERER_ORG_DOMAIN=$orderer_org_domain

    kube_apply_template "$COMMON_JOBS_TEMPLATES_PATH/create-channel-job.yaml" $k8s_namespace
    kube_wait_until_job_completed "$COMMON_JOBS_TEMPLATES_PATH/create-channel-job.yaml" $k8s_namespace
}

function join_channel() {
    local channel_name=$1
    local joining_org_name=$2
    local joining_org_domain=$3
    local orderer_org_name=$4
    local orderer_org_domain=$5

    local k8s_namespace=$6

    # exports to replace in the template
    export CHANNEL_NAME=$channel_name
    export JOINING_ORG_NODE="peer0"
    export JOINING_ORG_NAME=$joining_org_name
    export JOINING_ORG_DOMAIN=$joining_org_domain
    export ORDERER_ORG_NAME=$orderer_org_name
    export ORDERER_ORG_DOMAIN=$orderer_org_domain

    kube_apply_template "$COMMON_JOBS_TEMPLATES_PATH/peer-join-channel-job.yaml" $k8s_namespace
    kube_wait_until_job_completed "$COMMON_JOBS_TEMPLATES_PATH/peer-join-channel-job.yaml" $k8s_namespace
}