#!/bin/bash

DOCKERHUB_OWNER=shinhwagk
DOCKERHUB_IMAGE_PREFIX=quayio
registry="quay.io"

RenameToDockerIo(){
    echo "shinhwagk/quayio_${1}_${2}:${3}"
}

checkImageExistInDockerHub(){
  curl -s -o/dev/null -w "%{http_code}" https://hub.docker.com/v2/repositories/${1}/tags/${2}
}

fun_output(){
  curl -s "https://quay.io/api/v1/repository/${1}/${2}/tag/?limit=100&page=${3}&onlyActiveTags=true"
}

fun_tags_length() {
    echo ${1} | jq '.tags | length'
}

func_tags() {
    echo ${1} | jq -r '.tags[].name'
}

func_image_transport() {
    local repo=${1}
    local image=${2}
    local PAGE=0
    while true; do
    local output=`fun_output ${repo} ${image} $PAGE`
    for tag in `func_tags ${output}`; do
        local exist=`checkImageExistInDockerHub ${DOCKERHUB_OWNER}/${DOCKERHUB_IMAGE_PREFIX}_${repo}_${image} ${tag}`
        if [ "${exist}" == "200" ]; then
            continue;
        fi
        docker pull -q ${registry}/${repo}/${image}:${tag}
        dockerioImage=`RenameToDockerIo $repo $image $tag`
        docker tag ${registry}/$repo/$image:${tag} ${dockerioImage}
        docker push ${dockerioImage}
    done
    local tag_len=`fun_tags_length ${output}`
    [ ${tag_len} -le 100 ] && break || let PAGE+=1
    done
}



# # Porcess quay.io
# registry="quay.io"
# echo "start process ${registry}"
# ls ${registry} | while read repo; do
#   echo "  start process ${registry} repo: ${repo}"
#   ls "${registry}/$repo" | while read image; do
#     echo "    start process ${registry} repo: ${repo} image: ${image}"
#     cat "${registry}/$repo/$image" | while read tag; do
#       echo "      start process ${registry} repo: ${repo} image: ${image} tag: ${tag}"
#       echo "        start pull ${registry}/$repo/$image:${tag}"
#       exist=`checkImageExistInDockerHub shinhwagk/quayio_${repo}_${image} ${tag}`
#       echo "code: ${exist}"
#       if [ "${exist}" == "200" ]; then
#         continue;
#       fi
#       docker pull -q ${registry}/$repo/$image:${tag}
#       echo "        success pull ${registry}/$repo/$image:${tag}"

#       echo "        start rename ${registry}/$repo/$image:${tag}"
#       dockerioImage=`RenameToDockerIo $repo $image $tag`
#       docker tag ${registry}/$repo/$image:${tag} ${dockerioImage}
#       echo "        success rename ${registry}/$repo/$image:${tag} -> ${dockerioImage}"

#       echo "        start push ${dockerioImage}"
#       docker push ${dockerioImage}
#       echo "        success push ${dockerioImage}"
#       echo "##############################################################################"
#     done
#   done
# done
