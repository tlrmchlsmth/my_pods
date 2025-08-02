FROM ubuntu:24.04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3.12 python3.12-dev python3-pip python3-venv \
        htop iotop strace lsof \
        iproute2 iputils-ping dnsutils curl iperf3 \
        hey wrk apache2-utils \
        jq ripgrep fzf bat fd-find less \
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
      rust-just \
      guidellm

# Install dotfiles
RUN git clone --depth=1 --filter=blob:none https://github.com/tlrmchlsmth/dotfiles .dotfiles\
    && cd .dotfiles \
    && bash install.sh \
    && rm -rf .git

# Make first time neovim startup seamless
RUN nvim --headless "+autocmd User LazyDone quitall" "+Lazy! sync" "+MasonUpdate" +qa


ARG VLLM_COMMIT=427a5a3d65701217b6cc160073d41a0de4b82368
RUN source ${VIRTUAL_ENV}/bin/activate \
    && git clone --filter=blob:none https://github.com/vllm-project/vllm.git \
    && cd vllm \
    && git remote add eicherseiji https://github.com/eicherseiji/vllm \
    && git fetch eicherseiji ${VLLM_COMMIT} --depth=1 \
    && git checkout --detach ${VLLM_COMMIT} \
    && apt-get install -y --no-install-recommends gcc-12 g++-12 libtcmalloc-minimal4 libnuma-dev ffmpeg libsm6 libxext6 libgl1 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 10 --slave /usr/bin/g++ g++ /usr/bin/g++-12 \
    && uv pip install --torch-backend auto --index-strategy unsafe-best-match \
      -r requirements/cpu-build.txt -r requirements/cpu.txt \
    && VLLM_TARGET_DEVICE=cpu python setup.py install

RUN cd /app \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Turn off auto-updates & prompts for oh-my-zsh
RUN echo "DISABLE_AUTO_UPDATE=true" >> $HOME/.zshrc.local
RUN echo "DISABLE_UPDATE_PROMPT=true" >> $HOME/.zshrc.local

CMD ["sleep", "infinity"]
