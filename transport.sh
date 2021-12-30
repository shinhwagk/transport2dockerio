#!/usr/bin/env bash

DOCKERHUB_OWNER=shinhwagk

current_ts=$(date -d "`date -d '-1 day' '+%F'`" +%s)

cat images | while read image; do
  source=`echo $image | awk '{print $1}'`
  target=`echo $image | awk '{print $2}'`
  target="${DOCKERHUB_OWNER}/${target}"
  docker pull $source
  docker tag $source $target
  echo "$source --> $target"
  docker push $target
  echo "$source --> $target success."
done