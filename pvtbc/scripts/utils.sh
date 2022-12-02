# Set an environment variable based on an optional override (TICKEN_NETWORK_{name})
# from the calling shell.  If the override is not available, assign the parameter
# to a default value.
function context() {
  local name=$1
  local default_value=$2
  local override_name=TICKEN_NETWORK_${name}

  export ${name}="${!override_name:-${default_value}}"
}

# replace the environment variables on the template and apply
# it to using kubectl command on the namespace passed by parameter
function kube_apply_template() {
  cat $1 | envsubst | kubectl -n $2 apply -f -
}

function kube_wait_until_pod_running() {
  cat $1 | envsubst | kubectl -n $2 wait --for=condition=Available=True -f -
}

function kube_wait_until_job_completed() {
  cat $1 | envsubst | kubectl -n $2 wait --for=condition=complete -f -
}