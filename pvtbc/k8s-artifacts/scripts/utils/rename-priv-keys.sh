function rename_priv_keys() {
  local path=$1
  local pk_filename=$2

  find $path -type f -name "*_sk" -print0 | while IFS= read -r -d '' file
  do
      # extract the path of the file
      filepath=$(dirname "$file")

      echo $filepath

      # rename the file
      mv -v "$file" "$filepath/${pk_filename}"
  done
}