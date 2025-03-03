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
	git checkout 9fb4a7a403f9da9ee48afd6817089be5f944a127 && \
	chown -R 1000:1000 /src

#######################################################################
FROM apt-updated as ai-hub-models

RUN apt install -y wget unzip

RUN wget -O- https://github.com/quic/sample-apps-for-qualcomm-linux/releases/download/GA1.2-rel/GA1.2-rel.zip > models.zip && unzip models.zip && mv GA1.2-rel/QCS6490 ./models && rm models.zip
RUN wget -O- https://cdn.foundries.io/aihub-models/models-2024-10-18.tar.gz | tar -xzv
RUN wget -O- https://cdn.foundries.io/aihub-models/media-2024-10-18.tar.gz | tar -xzv && mv media/* models/ && rmdir media

# for mono-depth sample
RUN wget -O models/midasv2.tflite https://qaihub-public-assets.s3.us-west-2.amazonaws.com/qai-hub-models/models/midas/midasv2_linux_assets/midasv2.tflite
RUN wget -O models/midasv2.dlc https://qaihub-public-assets.s3.us-west-2.amazonaws.com/qai-hub-models/models/midas/midasv2_linux_assets/midasv2.dlc
RUN wget -O models/monodepth.labels https://qaihub-public-assets.s3.us-west-2.amazonaws.com/qai-hub-models/models/midas/midasv2_linux_assets/monodepth.labels
RUN wget -O models/inception_v3_quantized.tflite 'https://huggingface.co/qualcomm/Inception-v3-Quantized/resolve/main/Inception-v3-Quantized.tflite'

RUN chown 1000:1000 models/*

#######################################################################
FROM base
COPY --from=gst-sample-apps /src /src
COPY --from=ai-hub-models /models /src/models

WORKDIR /src/gst-plugins-qti-oss/gst-sample-apps
COPY dev-shell gst-build-samples run-on-host.sh /usr/local/bin/

RUN mkdir -p /apps

RUN gst-build-samples

ENTRYPOINT ["/bin/sh", "/usr/local/bin/run-on-host.sh"]
