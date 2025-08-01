FROM ubuntu:24.04

WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3.12 python3.12-dev python3-pip python3-venv \
        htop iotop strace lsof \
        iproute2 iputils-ping dnsutils curl wget iperf3 \
        hey wrk apache2-utils \
        jq ripgrep fd-find less \
        git vim \
        tmux zsh \
        build-essential ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --break-system-packages uv 
RUN uv venv -p 3.12
RUN uv pip install \
      just \
      guidellm

RUN git clone https://github.com/tlrmchlsmth/dotfiles \
    && cd dotfiles \
    && bash install.sh

ENV VLLM_USE_PRECOMPILED=1
ARG VLLM_COMMIT=427a5a3d65701217b6cc160073d41a0de4b82368

RUN git clone https://github.com/vllm-project/vllm.git \
    && cd vllm \
    && git remote add eicherseiji https://github.com/eicherseiji/vllm \
    && git fetch eicherseiji \
    && git checkout ${VLLM_COMMIT}

CMD ["sleep", "infinity"]
