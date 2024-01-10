FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    HF_HUB_ENABLE_HF_TRANSFER=0

ENV PATH="${HOME}/miniconda3/bin:${PATH}"
ARG PATH="${HOME}/miniconda3/bin:${PATH}"
ENV PATH="/app/ngc-cli:${PATH}"
ARG PATH="/app/ngc-cli:${PATH}"

RUN mkdir -p /tmp/model && \
    chown -R 1001:1001 /tmp/model && \
    mkdir -p /tmp/data && \
    chown -R 1001:1001 /tmp/data

RUN apt-get update &&  \
    apt-get upgrade -y &&  \
    apt-get install -y \
    build-essential \
    cmake \
    curl \
    ca-certificates \
    gcc \
    git \
    locales \
    net-tools \
    wget \
    libpq-dev \
    libsndfile1-dev \
    libgl1 \
    libgl1 \
    unzip \
    libgl1 \
    git \
    # Removed Git LFS installation command \
    libgl1 \
    unzip \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean


RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    git lfs install

WORKDIR /app
RUN mkdir -p /app/.cache
ENV HF_HOME="/app/.hf"
RUN chown -R 1001:1001 /app
USER 1001
ENV HOME=/app

ENV PYTHONPATH=$HOME/app \
    PYTHONUNBUFFERED=1 \
    GRADIO_ALLOW_FLAGGING=never \
    GRADIO_NUM_PORTS=1 \
    GRADIO_SERVER_NAME=0.0.0.0 \
    SYSTEM=spaces


RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && bash miniconda.sh -b -p /app/miniconda && rm -f miniconda.sh \
    && sh Miniconda3-latest-Linux-x86_64.sh -b -p /app/miniconda \
    && rm -f Miniconda3-latest-Linux-x86_64.sh
ENV PATH /app/miniconda/bin:$PATH

RUN conda create -p /app/env -y python=3.10

SHELL ["conda", "run","--no-capture-output", "-p","/app/env", "/bin/bash", "-c"]

RUN conda install pytorch torchvision torchaudio -c pytorch -c nvidia && \
    conda clean -ya

COPY --chown=1000:1000 . /app/
RUN pip install -e . && \
    python -m nltk.downloader punkt && \
    autotrain setup && \
    pip install flash-attn && \
    pip cache purge