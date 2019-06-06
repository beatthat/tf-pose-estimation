#!/bin/bash -x

DATA_PATH=${1} #/docker_host/data/video-01-clip-01

INPUT_IMAGES=${DATA_PATH}/video.mp4
OUTPUT=${DATA_PATH}/out
INPUT_KEYPOINTS=${DATA_PATH}/keypoints.npz

DETECTRON_EXTRA_DIR=${2:-$DETECTRON_EXTRA_WORKING_COPY}
DETECTRON_DIR=${3:-$DETECTRON_HOME}

CONFIG=${DETECTRON_DIR}/configs/12_2017_baselines/e2e_keypoint_rcnn_R-101-FPN_s1x.yaml
WTS=https://dl.fbaipublicfiles.com/detectron/37698009/12_2017_baselines/e2e_keypoint_rcnn_R-101-FPN_s1x.yaml.08_45_57.YkrJgP6O/output/train/keypoints_coco_2014_train:keypoints_coco_2014_valminusminival/generalized_rcnn/model_final.pkl
IMG_EXT=jpg

python ${DETECTRON_EXTRA_DIR}/tools/infer_boxes_and_keypoints.py \
    --cfg ${CONFIG}  \
    --output-dir ${OUTPUT} \
    --image-ext ${IMG_EXT} \
    --boxes-and-keypoints-source ${INPUT_KEYPOINTS} \
    --wts ${WTS} \
    ${INPUT_IMAGES}