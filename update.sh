#!/bin/bash

if [[ ${1} == "checkdigests" ]]; then
    export DOCKER_CLI_EXPERIMENTAL=enabled
    image="alpine"
    tag="3.14"
    manifest=$(docker manifest inspect ${image}:${tag})
    [[ -z ${manifest} ]] && exit 1
    digest=$(echo "${manifest}" | jq -r '.manifests[] | select (.platform.architecture == "amd64" and .platform.os == "linux").digest') && sed -i "s#FROM ${image}@.*\$#FROM ${image}@${digest}#g" ./linux-amd64.Dockerfile  && echo "${digest}"
    #digest=$(echo "${manifest}" | jq -r '.manifests[] | select (.platform.architecture == "arm" and .platform.os == "linux" and .platform.variant == "v7").digest') && sed -i "s#FROM ${image}@.*\$#FROM ${image}@${digest}#g" ./linux-arm-v7.Dockerfile && echo "${digest}"
    #digest=$(echo "${manifest}" | jq -r '.manifests[] | select (.platform.architecture == "arm64" and .platform.os == "linux").digest') && sed -i "s#FROM ${image}@.*\$#FROM ${image}@${digest}#g" ./linux-arm64.Dockerfile  && echo "${digest}"
elif [[ ${1} == "tests" ]]; then
    echo "Listing packages..."
    docker run --rm --entrypoint="" "${2}" apk -vv info | sort
    echo "Show rclone version info..."
    docker run --rm --entrypoint="" "${2}" rclone version
    echo "Show gclone version info..."
    docker run --rm --entrypoint="" "${2}" gclone version
    echo "Show crop help info..."
    docker run --rm --entrypoint="" "${2}" crop help
else
    version_gclone=$(curl -u "${GITHUB_ACTOR}:${GITHUB_TOKEN}" -fsSL "https://api.github.com/repos/l3uddz/rclone/commits/feat/sa-cycle" | jq -r .sha)
    [[ -z ${version_gclone} ]] && exit 1
    version_rclone=$(curl -u "${GITHUB_ACTOR}:${GITHUB_TOKEN}" -fsSL "https://api.github.com/repos/rclone/rclone/tags" | jq -r .[0].name | sed s/v//)
    [[ -z ${version_rclone} ]] && exit 1
    version_crop=$(curl -u "${GITHUB_ACTOR}:${GITHUB_TOKEN}" -fsSL "https://api.github.com/repos/l3uddz/crop/commits/master" | jq -r .sha)
    [[ -z ${version_crop} ]] && exit 1
    echo '{"version":"'"${version_crop}"'","gclone_version":"'"${version_gclone}"'","rclone_version":"'"${version_rclone}"'"}' | jq . > VERSION.json
    echo "##[set-output name=version;]${version_crop}/${version_rclone}/${version_gclone}"
fi
