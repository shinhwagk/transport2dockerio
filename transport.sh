#!/bin/bash

RenameToDockerIo(){
    echo "shinhwagk/quayio_${1}_${2}:${3}"
}

checkImageExistInDockerHub(){
  curl -s -o/dev/null -w "%{http_code}" https://hub.docker.com/v2/repositories/${1}/tags/${2}
}

# Porcess quay.io
registry="quay.io"
echo "start process ${registry}"
ls ${registry} | while read repo; do
  echo "  start process ${registry} repo: ${repo}"
  ls "${registry}/$repo" | while read image; do
    echo "    start process ${registry} repo: ${repo} image: ${image}"
    cat "${registry}/$repo/$image" | while read tag; do
      echo "      start process ${registry} repo: ${repo} image: ${image} tag: ${tag}"
      echo "        start pull ${registry}/$repo/$image:${tag}"
      exist=`checkImageExistInDockerHub shinhwagk/quayio_${repo}_${image} ${tag}`
      echo "code: ${exist}"
      if [ "${exist}" == "200" ]; then
        continue;
      fi
      docker pull -q ${registry}/$repo/$image:${tag}
      echo "        success pull ${registry}/$repo/$image:${tag}"

      echo "        start rename ${registry}/$repo/$image:${tag}"
      dockerioImage=`RenameToDockerIo $repo $image $tag`
      docker tag ${registry}/$repo/$image:${tag} ${dockerioImage}
      echo "        success rename ${registry}/$repo/$image:${tag} -> ${dockerioImage}"

      echo "        start push ${dockerioImage}"
      docker push ${dockerioImage}
      echo "        success push ${dockerioImage}"
      echo "##############################################################################"
    done
  done
done
