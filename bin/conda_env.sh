#!/usr/bin/env bash

PROJECT_ROOT=$(git rev-parse --show-toplevel 2> /dev/null)
VENV_NAME=${PROJECT_ROOT##*/}
FORCE=0
# DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DIR=$(pwd)
REQUIREMENTS="./requirements.txt"

while getopts ":fn:r:" opt; do
  case ${opt} in
    f )
      FORCE=1
      ;;
    n )
      VENV_NAME=$OPTARG
      ;;
    r )
      REQUIREMENTS=$OPTARG
      ;;
  esac
done
shift $((OPTIND -1))

if conda env list | grep -q "${VENV_NAME}" ; then
    if [ "${FORCE}" = "1" ]; then
        conda env remove -y --name ${VENV_NAME}
    else
        exit 0
    fi
fi

conda env create -f ${DIR}/environment.yml --name ${VENV_NAME}

if [ -f "${REQUIREMENTS}" ]; then
    source ${CONDA_PREFIX}/etc/profile.d/conda.sh && \
    conda activate ${VENV_NAME} && \
    pip install -r ${REQUIREMENTS} && \
    conda deactivate
fi