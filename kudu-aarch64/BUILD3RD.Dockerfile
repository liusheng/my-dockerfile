FROM liusheng2048/kudu-aarch64:no3rd

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

#
ENV PARALLEL 6

ARG repo_src=liusheng
ARG pr_num=8
# For TSAN: 3rdparty_type=tsan {common uninstrumented tsan}, default is: common uninstrumented
ARG build_type=all

RUN git clone https://github.com/$repo_src/kudu \
    && cd kudu \
    && git fetch origin pull/$pr_num/head:build-on-aarch64 \
    && git checkout build-on-aarch64 \
    && bash -ex thirdparty/build-if-necessary.sh $build_type 2>&1 |tee -a ~/kudu-build3rd.log