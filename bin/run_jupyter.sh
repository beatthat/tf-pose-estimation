#!/bin/bash
PWD=`pwd`
DIR=${1:-$PWD}
jupyter notebook --ip=0.0.0.0 --allow-root ${DIR}