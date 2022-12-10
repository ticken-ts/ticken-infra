source_path=$1
pk_filename=$2

find $source_path -type f -name "*_sk" -print0 | while IFS= read -r -d '' file
do
  # extract the path of the file
  filepath=$(dirname "$file")

  # rename the file
  mv -v "$file" "$filepath/${pk_filename}" &> /dev/null
done