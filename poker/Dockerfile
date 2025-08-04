# ---------- Stage 1: build vLLM wheel ----------
FROM ubuntu:24.04 AS vllm-builder
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
WORKDIR /build
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.12 python3.12-dev python3-pip python3-venv \
    git curl ca-certificates \
    gcc-12 g++-12 libtcmalloc-minimal4 libnuma-dev ffmpeg libsm6 libxext6 libgl1 \
    cmake ninja-build \
    && rm -rf /var/lib/apt/lists/*

# Install uv and create venv
ADD https://astral.sh/uv/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && rm /uv-installer.sh
ENV PATH="/root/.local/bin/:$PATH"
RUN uv venv -p 3.12
ENV VIRTUAL_ENV=/build/.venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

# Fetch vLLM source
ARG VLLM_COMMIT=309c1bb822c94436e8beff60d68404b4cecd62b8
RUN git clone --filter=blob:none https://github.com/vllm-project/vllm.git && \
    cd vllm && \
    git fetch --no-tags origin "${VLLM_COMMIT}" && \
    git checkout --detach "${VLLM_COMMIT}"

# Use gcc-12
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 10 \
    --slave /usr/bin/g++ g++ /usr/bin/g++-12

# Install vLLM deps into with CPU torch
RUN cd vllm && \
    uv pip install --python "${VIRTUAL_ENV}/bin/python" \
      --torch-backend cpu --index-strategy unsafe-best-match \
      -r requirements/cpu-build.txt -r requirements/cpu.txt

# Ensure pip/wheel available in the venv (uv doesn't guarantee pip)
RUN python -m ensurepip --upgrade && \
    python -m pip install --upgrade pip setuptools wheel

# Build wheel without isolation so it reuses CPU torch from the venv
RUN cd vllm && \
    VLLM_TARGET_DEVICE=cpu python -m pip wheel \
      --no-deps --no-build-isolation -w /dist .


# ---------- Stage 2: runtime ----------
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
        ca-certificates \
        # runtime libs for vLLM wheel built above
        libtcmalloc-minimal4 libnuma1 libsm6 libxext6 libgl1 \
    && rm -rf /var/lib/apt/lists/*

# Install uv
ADD https://astral.sh/uv/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && rm /uv-installer.sh
ENV PATH="/root/.local/bin/:$PATH"

# Create venv and set as default
RUN uv venv -p 3.12
ENV VIRTUAL_ENV=/app/.venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

# Base Python deps you had
RUN uv pip install --python "${VIRTUAL_ENV}/bin/python" \
      rust-just \
      guidellm

# Copy vLLM wheel from builder and install (force CPU Torch)
COPY --from=vllm-builder /dist/*.whl /tmp/wheels/
RUN uv pip install --python "${VIRTUAL_ENV}/bin/python" \
      --torch-backend cpu --index-strategy unsafe-best-match \
      /tmp/wheels/vllm-*.whl && \
    rm -rf /tmp/wheels

# Install dotfiles
RUN git clone --depth=1 --filter=blob:none https://github.com/tlrmchlsmth/dotfiles .dotfiles \
    && cd .dotfiles \
    && PIP_BREAK_SYSTEM_PACKAGES=1 bash install.sh \
    && rm -rf .git

# Make first time neovim startup seamless (ignore failure if nvim not present yet)
RUN nvim --headless "+autocmd User LazyDone quitall" "+Lazy! sync" "+MasonUpdate" +qa || true

# Cleanup
RUN apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# Turn off auto-updates & prompts for oh-my-zsh
RUN echo "DISABLE_AUTO_UPDATE=true" >> $HOME/.zshrc.local && \
    echo "DISABLE_UPDATE_PROMPT=true" >> $HOME/.zshrc.local

CMD ["sleep", "infinity"]

