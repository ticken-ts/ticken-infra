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

function kube_show_template() {
  cat $1 | envsubst
}

function kube_wait_until_pod_running() {
  cat $1 | envsubst | kubectl -n $2 wait --for=condition=Available=True -f -
}

function kube_wait_until_job_completed() {
  cat $1 | envsubst | kubectl -n $2 wait --for=condition=complete -f -
}


function get_folder_full_path() {
    relativePath=$1
    echo "$(cd "$(dirname "$relativePath")"; pwd)/$(basename "$relativePath")"
}

function get_file_full_path() {
    relativePath=$1
    echo "$(cd "$(dirname "$relativePath")"; pwd)"
}

function replace() {
    local orginal=$1
    local old_value=$2
    local new_value=$3

    echo "${orginal/$old_value/$new_value}"
}

function copy_recursively() {
  source=$1
  target=$2
  exclude=$3

  # NOTE: we need to initialize target to
  # determine the full path. If target do not
  # exist, get_folder_full_path is going to fails
  mkdir -p $target

  full_source=$(get_folder_full_path $source)
  full_target=$(get_folder_full_path $target)

  # todo -> handle without excluding
  find $full_source -type f -not -path "${full_source}/${exclude}/*" -prune -print0 | while IFS= read -r -d '' file
  do
    # extract the path of the file
    filename=$(basename "$file")

    # create a the new path replacing the the
    # new path in place of the old path
    source_file_path=$(get_file_full_path "$file")
    target_file_path=$(replace $source_file_path $full_source $full_target)

    # create the new path if not exists
    mkdir -p $target_file_path

    cp "$source_file_path/$filename" "$target_file_path/$filename"
  done
}