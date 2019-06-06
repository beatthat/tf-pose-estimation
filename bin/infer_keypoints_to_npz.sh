#!/bin/bash -x

DATA_PATH=${1} #/docker_host/data/video-01-clip-01
DETECTRON_EXTRA_DIR=${2:-$DETECTRON_EXTRA_WORKING_COPY}
DETECTRON_DIR=${3:-$DETECTRON_HOME}

INPUT=${DATA_PATH}/video.mp4
OUTPUT=${DATA_PATH}/keypoints.npz

CONFIG=${DETECTRON_DIR}/configs/12_2017_baselines/e2e_keypoint_rcnn_R-101-FPN_s1x.yaml
WTS=https://dl.fbaipublicfiles.com/detectron/37698009/12_2017_baselines/e2e_keypoint_rcnn_R-101-FPN_s1x.yaml.08_45_57.YkrJgP6O/output/train/keypoints_coco_2014_train:keypoints_coco_2014_valminusminival/generalized_rcnn/model_final.pkl

python ${DETECTRON_EXTRA_DIR}/tools/infer_boxes_and_keypoints.py \
    --cfg ${CONFIG}  \
    --output-boxes-and-keypoints-npz ${OUTPUT} \
    --wts ${WTS} \
    ${INPUT}