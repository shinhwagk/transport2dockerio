#!/usr/bin/env bash

DOCKERHUB_OWNER=shinhwagk
DOCKERHUB_IMAGE_PREFIX="quayio"
registry="quay.io"
RequestLimit=10

RenameToDockerIo(){
    echo "${DOCKERHUB_OWNER}/${DOCKERHUB_IMAGE_PREFIX}_${1}_${2}:${3}"
}

# exist if return http_code: 200
checkImageExistInDockerHub(){
  curl -s -o /dev/null -w "%{http_code}" https://hub.docker.com/v2/repositories/${1}/tags/${2}
}

fun_output(){
  curl -s "https://quay.io/api/v1/repository/${1}/${2}/tag/?limit=${RequestLimit}&page=${3}&onlyActiveTags=true" | base64
}

fun_tags_length() {
    echo "${1}" | base64 -d | jq '.tags | length'
}

func_tags() {
    echo "${1}" | base64 -d | jq -r '.tags[].name'
}

func_transport() {
    docker pull -q ${registry}/${1}/${2}:${3}
    dockerioImage=`RenameToDockerIo $1 $2 $3`
    docker tag ${registry}/$1/$2:${3} ${dockerioImage}
    docker push ${dockerioImage} > /dev/null
}

func_image_transport() {
    local repo=${1}
    local image=${2}
    local page=1
    while true; do
        local output=`fun_output ${repo} ${image} ${page}`
        local tags_len=`fun_tags_length "${output}"`
        if [ ${tags_len} -ne 0 ]; then
            break;
        else
            let page+=1
        fi
        for tag in `func_tags "${output}"`; do
            echo "process ${repo} ${image} ${page}."
            local exist=`checkImageExistInDockerHub ${DOCKERHUB_OWNER}/${DOCKERHUB_IMAGE_PREFIX}_${repo}_${image} ${tag}`
            if [ "${exist}" == "200" ]; then
                continue;
            fi
            func_transport $repo $image $tag &
        done
        wait;
    done
}

bootstrap(){
    ls ${registry} | while read repo; do
        cat "${registry}/$repo" | while read image; do
            func_image_transport ${repo} ${image}
        done
    done
}

bootstrap

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
