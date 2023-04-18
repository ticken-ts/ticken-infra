function logging_init() {
  rm -rf ${BASE_LOGS_PATH}
  mkdir -p ${BASE_LOGS_PATH}

  # store default stdout and stderr
  # stdout is stored in fd 3
  # stderr is stored in fd 4
  exec 3>&1
  exec 4>&2

  # redirect stdout and stderr to
  # log files
  exec 1>>${DEBUG_FILE}
  exec 2>>${DEBUG_FILE}
}

function log_title() {
  local message=$1
  echo "************* ${message} ************* \n"
  echo "************* ${message} ************* \n" 1>&3 2>&4
}

function log_op() {
  local message=$1
  echo "*** ${message}"
  echo "*** ${message}" 1>&3 2>&4
}

function push_step() {
  local message=$1
  printf "%s" "  - ${message}: "
  printf "%s" "  - ${message}: " 1>&3 2>&4
}

function pop_step() {
  if [ $# -eq 0 ]; then
    printf "%s \n" "✅" 1>&3 2>&4
    return
  fi

  local res=$1

  if [ $res -eq 0 ]; then
    printf "%s \n" "✅" 1>&3 2>&4

  elif [ $res -eq 1 ]; then
    printf "%s \n" "⚠️" 1>&3 2>&4

  elif [ $res -eq 2 ]; then
    printf "%s \n" "☠️" 1>&3 2>&4

  elif [ $res -eq 127 ]; then
    printf "%s \n" "☠️" 1>&3 2>&4

  else
    printf "%s \n" "" 1>&3 2>&4
  fi

  if [ $res -ne 0 ]; then
    tail -2 network-debug.log 1>&3 2>&4
  fi
}