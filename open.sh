#!/usr/bin/env bash

# $1 dir
# $2 url
getMp3ByParts() {
  name=$(echo "$2" | sed 's/https:\/\/cf-hls-media.sndcdn.com\/media\/\(.*\.mp3\).*/\1/g')
  name=$(echo "$name" | sed 's/\//-/g')
  curl -o "$1"/"${name}" "$2"
}

# $1 dir
# $2 output
concat() {
   parts=(`ls -rt ${1}| xargs`)
   for i in ${parts[*]}
   do
     s+="${1}/"${i}"|"
   done
   ffmpeg -i "concat:${s}" -acodec copy "$2"
}


while getopts d:o: opt;
do
  case ${opt} in
    d)
      dir=${OPTARG//,/ }
      ;;
    o)
      output=${OPTARG//,/ }
      ;;
    ?)
      exit 1
      ;;
   esac
done

if [[ -z ${dir} ]];then
  printf 'input -d dir\n'
  exit 1
fi

if [[ -o ${output} ]];then
  printf 'input -o output file\n'
  exit 1
fi

if [[ -d ${dir} ]];then
  rm -r "${dir}"
fi
mkdir "${dir}"

ARRAY=($(cat playlist.m3u8 |grep -v '#'))
for i in ${ARRAY[*]}
do
  getMp3ByParts "$dir" "$i"
done

concat "${dir}" "${output}"
