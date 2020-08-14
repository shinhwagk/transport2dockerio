#!/bin/bash

RenameToDockerIo(){
    echo "shinhwagk/quayio_${1}_${2}:${3}"
}

# Porcess quay.io
ls quay.io | while read repo; do
  ls "quay.io/$repo" | while read image; do
    cat "quay.io/$repo/$image" | while read tag; do
      echo "docker pull quay.io/$repo/$image:${tag}"
      dockerioImage=`RenameToDockerIo $repo $image $tag`
      docker push ${dockerioImage}
    done
  done
done
