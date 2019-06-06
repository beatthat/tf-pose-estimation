SHELL:=/bin/bash
PROJECT=$(shell git rev-parse --show-toplevel 2> /dev/null)
PROJECT_NAME=$(shell v='$(PROJECT)'; echo "$${v\#\#*/}")
PROJECT_BIN=$(PROJECT)/bin
CONDA_ENV=$(PROJECT_NAME)
IMAGE_TEST=/home/larry/projects/pose-detection/tests/api/features/resources/images/example_01/image.png

.PHONY: test-env
conda-env-create:
	$(PROJECT_BIN)/conda_env.sh -f -n ${CONDA_ENV}

compile: 
	bash -c "source $(CONDA_PREFIX)/etc/profile.d/conda.sh && \
		conda activate ${CONDA_ENV} && \
		cd tf_pose/pafprocess && \
		swig -python -c++ pafprocess.i && python3 setup.py build_ext --inplace"


model-download:
	cd models/graph/cmu && \
		sh download.sh

run:
	python run.py --model=cmu --resize=432x368 --image=${IMAGE_TEST}