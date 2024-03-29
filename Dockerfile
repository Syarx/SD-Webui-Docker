# FROM runpod/stable-diffusion-models:2.1 as build

FROM ubuntu:22.04 AS runtime

RUN rm -rf /workspace && mkdir /workspace && mkdir -p /root/.cache/huggingface

# COPY --from=build /models/v2-1_768-ema-pruned.ckpt /workspace/v2-1_768-ema-pruned.ckpt
# COPY --from=build /models/v2-1_768-ema-pruned.yaml /workspace/v2-1_768-ema-pruned.yaml
# COPY --from=build /root/.cache/huggingface /root/.cache/huggingface

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && \
apt install -y  --no-install-recommends \
software-properties-common \
git \
openssh-server \
libglib2.0-0 \
libsm6 \
libxrender1 \
libxext6 \
ffmpeg \
wget \
curl \
unzip \
zip \
nano \
python3-pip python3 python3.10-venv \
apt-transport-https ca-certificates && \
update-ca-certificates

WORKDIR /workspace

RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

RUN git clone https://github.com/camenduru/sd-civitai-browser /workspace/stable-diffusion-webui/extensions/sd-civitai-browser
RUN git clone https://github.com/d8ahazard/sd_dreambooth_extension /workspace/stable-diffusion-webui/extensions/sd_dreambooth_extension
RUN git clone https://github.com/camenduru/stable-diffusion-webui-huggingface /workspace/stable-diffusion-webui/extensions/stable-diffusion-webui-huggingface
RUN wget https://huggingface.co/Lykon/DreamShaper/resolve/main/Dreamshaper_3.32_baked_vae_clip_fix_half.ckpt -P /workspace/stable-diffusion-webui/models/Stable-diffusion/

WORKDIR /workspace/stable-diffusion-webui

RUN python3 -m venv /workspace/stable-diffusion-webui/venv
ENV PATH="/workspace/stable-diffusion-webui/venv/bin:$PATH"

RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python get-pip.py
# RUN pip install -U jupyterlab ipywidgets jupyter-archive
# RUN jupyter nbextension enable --py widgetsnbextension

ADD install.py .
RUN python -m install --skip-torch-cuda-test

RUN apt clean && rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

ADD ui-config.json /workspace/stable-diffusion-webui/ui-config.json
ADD relauncher.py .
ADD webui-user.sh .
ADD start.sh /start.sh
RUN chmod a+x /start.sh

SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/start.sh" ]
