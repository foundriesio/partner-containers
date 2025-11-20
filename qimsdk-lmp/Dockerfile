FROM debian:bullseye AS base

RUN \
	apt update && \
	apt install -y \
		build-essential \
		cmake \
		gdb \
		git \
		gstreamer1.0-tools \
		libjson-glib-dev \
		libglib2.0-dev \
		libgstreamer1.0-dev \
		libgstreamer-plugins-base1.0-dev \
		libsoup2.4-dev \
		openssh-client \
		openssh-server \
		sshpass \
		strace \
		sudo \
		vim \
		wget && \
	rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

RUN \
	addgroup --gid 1000 fio && \
	adduser --uid 1000 --gid 1000 fio && \
	adduser fio sudo && \
	echo "fio:fio" | chpasswd

#######################################################################
FROM debian:bullseye AS apt-updated
RUN apt update

#######################################################################
FROM apt-updated AS gst-sample-apps

# QLI 1.6 release
ARG gst_plugins_qti_oss_tag=LE.QCQIMPRODUCT.1.0.r1-06200-QIM.0

RUN apt install -y git

RUN \
	mkdir -p /src && \
	cd /src && \
	git clone https://git.codelinaro.org/clo/le/platform/vendor/qcom-opensource/gst-plugins-qti-oss.git && \
	cd gst-plugins-qti-oss && \
	git checkout ${gst_plugins_qti_oss_tag}

# TEMP: Patch to fix daisychain-detection-classification regression
COPY 0001-gst-ai-daisychain-detection-classification-includes.patch /src
# TEMP: Patch to avoid log spam for warning
COPY 0002-gst-sample-apps-set-log_level-to-error-only-for-dsp-.patch /src

RUN \
	cd /src/gst-plugins-qti-oss && \
	git apply ../0001-gst-ai-daisychain-detection-classification-includes.patch && \
	git apply ../0002-gst-sample-apps-set-log_level-to-error-only-for-dsp-.patch && \
	chown -R 1000:1000 /src

#######################################################################
FROM apt-updated AS ai-hub-models

# Release: https://github.com/quic/sample-apps-for-qualcomm-linux/releases/tag/GA1.6-rel
# Doc: https://docs.qualcomm.com/bundle/publicresource/topics/80-70022-50/overview.html (QLI 1.6 release: 2025-10-16)
# Dependencies: Qualcomm AI® Runtime SDK v2.38 and LiteRT (or TFLite) v2.16.1
# NOTE: This is located in the apt-updated build step for inheritance reasons
ARG qli_sample_apps_release=GA1.6-rel
ARG qair_sdk_release=v2.38
ARG qli_machine=QCS6490
ARG hf_model_tag=v0.40.1

RUN apt install -y wget unzip

RUN wget -O- https://github.com/quic/sample-apps-for-qualcomm-linux/releases/download/${qli_sample_apps_release}/${qair_sdk_release}_${qli_machine}.zip > models.zip && unzip models.zip && mv ${qair_sdk_release}_${qli_machine}/ ./models && rm models.zip
# GA1.6-rel is missing labels.zip; there was a GA1.6-labels release on the same day instead (not sure if this will continue)
# RUN wget -O- https://github.com/quic/sample-apps-for-qualcomm-linux/releases/download/${qli_sample_apps_release}/labels.zip > labels.zip && unzip labels.zip && rm labels.zip
RUN wget -O- https://github.com/quic/sample-apps-for-qualcomm-linux/releases/download/GA1.6-labels/labels.zip > labels.zip && unzip labels.zip && rm labels.zip
RUN wget -O- https://cdn.foundries.io/aihub-models/media-2024-10-18.tar.gz | tar -xzv

# TEMP: the classification.json in the GA1.6 release has an "off by 1 error" let's remove it and use our custom one that starts with "tench" as index 0 (instead of index 1)
RUN rm labels/classification.json
COPY classification.json /labels/

# TEMP: Remove the inceptionv3.dlc from the GA1.6 release: it's been modified to use "tench" as index 1
# Instead, use the standard indexing dlc model from HuggingFace (below)
# This means we can use the same classification.json file between the tflite and dlc models
RUN rm models/inceptionv3.dlc

# HuggingFace DLC models
RUN wget -O models/inceptionv3.dlc https://huggingface.co/qualcomm/Inception-v3/resolve/${hf_model_tag}/Inception-v3_w8a8.dlc

# HuggingFace TFLITE models
# Use the same order from: https://github.com/quic/sample-apps-for-qualcomm-linux/blob/GA1.6-rel/download_artifacts.sh#L180
RUN wget -O models/inception_v3_quantized.tflite https://huggingface.co/qualcomm/Inception-v3/resolve/${hf_model_tag}/Inception-v3_w8a8.tflite
RUN wget -O models/deeplabv3_plus_mobilenet_quantized.tflite https://huggingface.co/qualcomm/DeepLabV3-Plus-MobileNet/resolve/${hf_model_tag}/DeepLabV3-Plus-MobileNet_w8a8.tflite
RUN wget -O models/midas_quantized.tflite https://huggingface.co/qualcomm/Midas-V2/resolve/${hf_model_tag}/Midas-V2_w8a8.tflite
RUN wget -O models/hrnet_pose_quantized.tflite https://huggingface.co/qualcomm/HRNetPose/resolve/${hf_model_tag}/HRNetPose_w8a8.tflite
RUN wget -O models/quicksrnetsmall_quantized.tflite https://huggingface.co/qualcomm/QuickSRNetSmall/resolve/${hf_model_tag}/QuickSRNetSmall_w8a8.tflite
RUN wget -O models/face_det_lite_quantized.tflite https://huggingface.co/qualcomm/Lightweight-Face-Detection/resolve/${hf_model_tag}/Lightweight-Face-Detection_w8a8.tflite
RUN wget -O models/facemap_3dmm_quantized.tflite https://huggingface.co/qualcomm/Facial-Landmark-Detection/resolve/${hf_model_tag}/Facial-Landmark-Detection_w8a8.tflite
RUN wget -O models/face_attrib_net_quantized.tflite https://huggingface.co/qualcomm/Facial-Attribute-Detection/resolve/${hf_model_tag}/Facial-Attribute-Detection_w8a8.tflite
# YamNet.tflite file is missing from the current HuggingFace release
# RUN wget -O models/yamnet.tflite https://huggingface.co/qualcomm/YamNet/resolve/${hf_model_tag}/YamNet.tflite
RUN wget -O models/yolox_quantized.tflite https://huggingface.co/qualcomm/Yolo-X/resolve/${hf_model_tag}/Yolo-X_w8a8.tflite

# Media files
RUN mkdir -p data media
RUN wget -O data/blendShape.bin https://raw.githubusercontent.com/quic/sample-apps-for-qualcomm-linux/refs/heads/main/artifacts/data/blendShape.bin
RUN wget -O data/meanFace.bin https://raw.githubusercontent.com/quic/sample-apps-for-qualcomm-linux/refs/heads/main/artifacts/data/meanFace.bin
RUN wget -O data/shapeBasis.bin https://raw.githubusercontent.com/quic/sample-apps-for-qualcomm-linux/refs/heads/main/artifacts/data/shapeBasis.bin
RUN wget -O media/video.mp4 https://raw.githubusercontent.com/quic/sample-apps-for-qualcomm-linux/refs/heads/main/artifacts/videos/video.mp4
RUN wget -O media/video1.mp4 https://raw.githubusercontent.com/quic/sample-apps-for-qualcomm-linux/refs/heads/main/artifacts/videos/video1.mp4
RUN wget -O media/video-flac.mp4 https://raw.githubusercontent.com/quic/sample-apps-for-qualcomm-linux/refs/heads/main/artifacts/videos/video-flac.mp4
RUN wget -O media/video-mp3.mp4 https://raw.githubusercontent.com/quic/sample-apps-for-qualcomm-linux/refs/heads/main/artifacts/videos/video-mp3.mp4

# Fix locations
RUN sed -i 's|/etc/data/|/opt/gst/data/|g' labels/facemap_3dmm_settings.json

RUN chown 1000:1000 models/* labels/* data/* media/*

#######################################################################
FROM base
COPY --from=gst-sample-apps /src /src
COPY --from=ai-hub-models /models /src/models
COPY --from=ai-hub-models /labels /src/labels
COPY --from=ai-hub-models /data /src/data
COPY --from=ai-hub-models /media /src/media

WORKDIR /src/gst-plugins-qti-oss/gst-sample-apps
COPY dev-shell gst-build-samples run-on-host.sh /usr/local/bin/

RUN mkdir -p /apps

RUN gst-build-samples

ENTRYPOINT ["/usr/local/bin/run-on-host.sh"]
