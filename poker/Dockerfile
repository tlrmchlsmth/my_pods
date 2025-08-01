FROM ubuntu:24.04

WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3.12 python3.12-dev python3-pip python3-venv \
        htop iotop strace lsof \
        iproute2 iputils-ping dnsutils curl iperf3 \
        hey wrk apache2-utils \
        jq ripgrep fd-find less \
        git \
        tmux zsh \
        nodejs npm \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install uv
ADD https://astral.sh/uv/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && rm /uv-installer.sh
ENV PATH="/root/.local/bin/:$PATH"

# Create venv and set as default
RUN uv venv -p 3.12
ENV VIRTUAL_ENV=/app/.venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

# Install python dependencies
RUN uv pip install --python "${VIRTUAL_ENV}/bin/python"\
      just \
      guidellm

# Install dotfiles
RUN git clone --depth=1 --filter=blob:none https://github.com/tlrmchlsmth/dotfiles \
    && cd dotfiles \
    && bash install.sh \
    && rm -rf .git
ENV APPIMAGE_EXTRACT_AND_RUN=1
RUN echo "APPIMAGE_EXTRACT_AND_RUN=1" >> $HOME/.zshrc.local
RUN echo "APPIMAGE_EXTRACT_AND_RUN=1" >> $HOME/.bashrc

# Make first time startup seamless
RUN nvim --headless "+Lazy! restore" +qa || nvim --headless "+Lazy! sync" +qa
RUN nvim --headless "+TSUpdateSync" +qa || true
RUN nvim --headless -c "MasonUpdate" -c "MasonToolsInstall" -c "qall" || true
RUN nvim --headless "+qall"

ENV VLLM_USE_PRECOMPILED=1
ARG VLLM_COMMIT=427a5a3d65701217b6cc160073d41a0de4b82368

RUN git clone --filter=blob:none https://github.com/vllm-project/vllm.git \
    && cd vllm \
    && git remote add eicherseiji https://github.com/eicherseiji/vllm \
    && git fetch eicherseiji ${VLLM_COMMIT} --depth=1 \
    && git checkout --detach ${VLLM_COMMIT} && \
    rm -rf .git

RUN cd /app \
    && apt-get purge -y git && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

CMD ["sleep", "infinity"]
