FROM debian:bullseye as base

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
FROM debian:bullseye as apt-updated
RUN apt update

#######################################################################
FROM apt-updated as gst-sample-apps

RUN apt install -y git

RUN \
	mkdir -p /src && \
	cd /src && \
	git clone https://git.codelinaro.org/clo/le/platform/vendor/qcom-opensource/gst-plugins-qti-oss.git && \
	cd gst-plugins-qti-oss && \
	git checkout LE.QCQIMPRODUCT.1.0.r1-05300-QIM.0 && \
	chown -R 1000:1000 /src

#######################################################################
FROM apt-updated as ai-hub-models

RUN apt install -y wget unzip

RUN wget -O- https://github.com/quic/sample-apps-for-qualcomm-linux/releases/download/GA1.4-rel/v2.32_QCS6490.zip > models.zip && unzip models.zip && mv v2.32_QCS6490/ ./models && rm models.zip
RUN wget -O- https://github.com/quic/sample-apps-for-qualcomm-linux/releases/download/GA1.4-rel/labels.zip > labels.zip && unzip labels.zip && rm labels.zip && cp labels/yolonas.labels labels/yolov8.labels
RUN wget -O- https://cdn.foundries.io/aihub-models/models-2024-10-18.tar.gz | tar -xzv && mv models/*.labels labels/
RUN wget -O- https://cdn.foundries.io/aihub-models/media-2024-10-18.tar.gz | tar -xzv

RUN wget -O models/inception_v3_quantized.tflite https://huggingface.co/qualcomm/Inception-v3-Quantized/resolve/main/Inception-v3-Quantized.tflite
RUN wget -O models/deeplabv3_plus_mobilenet_quantized.tflite https://huggingface.co/qualcomm/DeepLabV3-Plus-MobileNet-Quantized/resolve/main/DeepLabV3-Plus-MobileNet-Quantized.tflite
RUN wget -O models/midas_quantized.tflite https://huggingface.co/qualcomm/Midas-V2-Quantized/resolve/main/Midas-V2-Quantized.tflite
RUN wget -O models/hrnet_pose_quantized.tflite https://huggingface.co/qualcomm/HRNetPoseQuantized/resolve/main/HRNetPoseQuantized.tflite
RUN wget -O models/midasv2.dlc https://qaihub-public-assets.s3.us-west-2.amazonaws.com/qai-hub-models/models/midas/midasv2_linux_assets/midasv2.dlc
RUN wget -O models/quicksrnetsmall_quantized.tflite https://huggingface.co/qualcomm/QuickSRNetSmall-Quantized/resolve/main/QuickSRNetSmall-Quantized.tflite
RUN wget -O models/face_det_lite_quantized.tflite https://huggingface.co/qualcomm/Lightweight-Face-Detection-Quantized/resolve/main/Lightweight-Face-Detection-Quantized.tflite
RUN wget -O models/mobilenet_v2_quantized.tflite https://huggingface.co/qualcomm/MobileNet-v2-Quantized/resolve/main/MobileNet-v2-Quantized.tflite
RUN wget -O models/facemap_3dmm_quantized.tflite https://huggingface.co/qualcomm/Facial-Landmark-Detection-Quantized/resolve/main/Facial-Landmark-Detection-Quantized.tflite
RUN wget -O models/face_attrib_net_quantized.tflite https://huggingface.co/qualcomm/Facial-Attribute-Detection-Quantized/resolve/main/Facial-Attribute-Detection-Quantized.tflite
RUN wget -O models/yamnet.tflite https://huggingface.co/qualcomm/YamNet/resolve/main/YamNet.tflite
RUN wget -O models/yolox_quantized.tflite https://huggingface.co/qualcomm/Yolo-X/resolve/2885648dda847885e6fd936324856b519d239ee1/Yolo-X_w8a8.tflite
RUN wget -O labels/monodepth.labels https://qaihub-public-assets.s3.us-west-2.amazonaws.com/qai-hub-models/models/midas/midasv2_linux_assets/monodepth.labels
RUN wget -O labels/detection.labels https://raw.githubusercontent.com/quic/sample-apps-for-qualcomm-linux/refs/heads/main/artifacts/labels/detection.labels

RUN mkdir -p data media
RUN wget -O data/blendShape.bin https://raw.githubusercontent.com/quic/sample-apps-for-qualcomm-linux/refs/heads/main/artifacts/data/blendShape.bin
RUN wget -O data/meanFace.bin https://raw.githubusercontent.com/quic/sample-apps-for-qualcomm-linux/refs/heads/main/artifacts/data/meanFace.bin
RUN wget -O data/shapeBasis.bin https://raw.githubusercontent.com/quic/sample-apps-for-qualcomm-linux/refs/heads/main/artifacts/data/shapeBasis.bin
RUN wget -O media/video.mp4 https://raw.githubusercontent.com/quic/sample-apps-for-qualcomm-linux/refs/heads/main/artifacts/videos/video.mp4
RUN wget -O media/video1.mp4 https://raw.githubusercontent.com/quic/sample-apps-for-qualcomm-linux/refs/heads/main/artifacts/videos/video1.mp4
RUN wget -O media/video-flac.mp4 https://raw.githubusercontent.com/quic/sample-apps-for-qualcomm-linux/refs/heads/main/artifacts/videos/video-flac.mp4
RUN wget -O media/video-mp3.mp4 https://raw.githubusercontent.com/quic/sample-apps-for-qualcomm-linux/refs/heads/main/artifacts/videos/video-mp3.mp4

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

# YOLOv8 needs to be manually exported by the user
#COPY yolov8_det_quantized.tflite /src/models

ENTRYPOINT ["/usr/local/bin/run-on-host.sh"]
