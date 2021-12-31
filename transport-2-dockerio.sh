#!/usr/bin/env bash

DOCKERHUB_OWNER=shinhwagk

cat dockerio_images

echo "" >> 2_dockerio_images
cat 2_dockerio_images | grep -v "^\s*$" | while read image; do
  if [[ ${image:0:10} = "k8s.gcr.io" ]]; then
    image_name="${image##*/}"
    new_image="${DOCKERHUB_OWNER}/kgi_${image_name}"
    echo $image_name $new_image
    docker pull $image
    docker tag $image $new_image
    docker push $new_image
    echo "$source --> $target success."
  fi
  # source=`echo $image | awk '{print $1}'`
  # target=`echo $image | awk '{print $2}'`
  # target="${DOCKERHUB_OWNER}/${target}"
  
  # echo "$source --> $target"
  # docker push $target
  # echo "$source --> $target success."
done

cat /dev/null > 2_dockerio_images