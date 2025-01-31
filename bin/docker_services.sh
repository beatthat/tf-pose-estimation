#!/usr/bin/env bash

usage () {
    echo $"
Usage: $0 docker-account 
        [-b build-directory] 
        [-o output-properties] 
        [-p docker-image-prefix] 
        [-r registry]  
        [-s services-directory] 
        [-t tag]
        [-u account] 
    build|push|push-local
"
}

cannonical () {
  local s=$1
  s=$(echo $s | tr [:upper:] [:lower:])
  s=$(echo $s | perl -pe 's/[^a-zA-Z0-9\-\n]+/-/g')
  echo $s
}

ORIGINAL_CALL="$0 $@"
BIN="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PWD="$(pwd)"
ROOT=$(git rev-parse --show-toplevel 2> /dev/null)
SERVICES_ROOT=${ROOT}/services
BUILD_DIR=${PWD}/build
DOCKER_REPO_PREFIX=$(cannonical ${ROOT##*/})
DOCKER_TAG=latest
DOCKER_REGISTRY_PREFIX=""
DOCKER_ACCOUNT_PREFIX=""

source ${BIN}/lib/getopts_long.bash

while getopts_long ":t:s:p:o:u:r:b: build-dir: account: registry: repo-prefix: services-root: tag:" OPT_KEY; do
  case ${OPT_KEY} in
    'b' | 'build-dir' )
      BUILD_DIR=$OPTARG
      ;;
    's' | 'services-root' )
      SERVICES_ROOT=$OPTARG
      ;;
    't' | 'tag' )
      DOCKER_TAG=$OPTARG
      ;;
    'p' | 'repo-prefix' )
      DOCKER_REPO_PREFIX=$OPTARG
      ;;
    'o' )
      OUTPUT_PROPERTIES=$OPTARG
      ;;
    'u' | 'account' )
      DOCKER_ACCOUNT_PREFIX="${OPTARG}/"
      ;;
    'r' | 'registry' )
      DOCKER_REGISTRY_PREFIX="${OPTARG}/"
      ;;
    '?' )
      echo "Invalid option: $OPTARG" 1>&2
      ;;
    ':' )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      ;;
  esac
done
shift $((OPTIND -1))

CMD=$1; shift;
case "$CMD" in
        build)
            cd $SERVICES_ROOT 
            for d in */; do
                service_name=${d%/}
                img=${DOCKER_REGISTRY_PREFIX}${DOCKER_ACCOUNT_PREFIX}${DOCKER_REPO_PREFIX}-${service_name}:${DOCKER_TAG}
                cd ${SERVICES_ROOT}/${d} && \
                    make docker-build DOCKER_IMAGE=${img}
            done
            ;;
        
        push)
            cd $SERVICES_ROOT 
            for d in */; do
                service_name=${d%/}
                img=${DOCKER_REGISTRY_PREFIX}${DOCKER_ACCOUNT_PREFIX}${DOCKER_REPO_PREFIX}-${service_name}:${DOCKER_TAG}
                docker push ${img}
            done
            ;;
        
        push-local)
            cd $SERVICES_ROOT 
            if [ -z "${DOCKER_REGISTRY_PREFIX}" ]; then
              DOCKER_REGISTRY_PREFIX="localhost:32000"
            fi
            echo "push service tags to local registry ${DOCKER_REGISTRY_PREFIX}..."
            for d in */; do
                service_name=${d%/}
                img=${DOCKER_ACCOUNT_PREFIX}${DOCKER_REPO_PREFIX}-${service_name}:${DOCKER_TAG}
                img_w_reg=${DOCKER_REGISTRY_PREFIX}${img}
                echo "  tagging ${img} as ${img_w_reg}"
                docker tag ${img} ${img_w_reg}
                docker push ${img_w_reg}
            done
            ;;

        properties)
            cd $SERVICES_ROOT 
            if [ -z "${OUTPUT_PROPERTIES}" ]; then
              OUTPUT_PROPERTIES=${BUILD_DIR}/config/docker_services.properties
            fi
            mkdir -p $(dirname ${OUTPUT_PROPERTIES})
            echo "# generated by ${ORIGINAL_CALL}" > ${OUTPUT_PROPERTIES}
            for d in */; do
                service_name=${d%/}
                tag=${DOCKER_REGISTRY_PREFIX}${DOCKER_ACCOUNT_PREFIX}${DOCKER_REPO_PREFIX}-${service_name}:${DOCKER_TAG}
                echo "${service_name}=${tag}" >> ${OUTPUT_PROPERTIES}
            done
            echo "" >> ${OUTPUT_PROPERTIES}
            ;;

        *)
            usage
            exit 1
 
esac