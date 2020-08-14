#!/bin/bash

RenameToDockerIo(){
    echo "shinhwagk/quayio_${1}_${2}:${3}"
}

# Porcess quay.io
echo "start process quay.io"
ls quay.io | while read repo; do
  echo "  start process quay.io repo: ${repo}"
  ls "quay.io/$repo" | while read image; do
    echo "    start process quay.io repo: ${repo} image: ${image}"
    cat "quay.io/$repo/$image" | while read tag; do
      echo "      start process quay.io repo: ${repo} image: ${image} tag: ${tag}"
      echo "        start pull quay.io/$repo/$image:${tag}"
      docker pull -q quay.io/$repo/$image:${tag}
      echo "        success pull quay.io/$repo/$image:${tag}"

      echo "        start rename quay.io/$repo/$image:${tag}"
      dockerioImage=`RenameToDockerIo $repo $image $tag`
      echo "        success rename quay.io/$repo/$image:${tag} -> ${dockerioImage}"

      echo "        start push ${dockerioImage}"
      docker push ${dockerioImage}
      echo "        success push ${dockerioImage}"
    done
  done
done
