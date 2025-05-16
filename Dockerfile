FROM ubuntu:latest

ENV NVIM_VERSION=0.11
ENV DEBIAN_FRONTEND=noninteractive

# Install build + runtime dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    unzip \
    ca-certificates \
    build-essential \
    cmake \
    ninja-build \
    gettext \
    libtool \
    libtool-bin \
    python3 \
    python3-pip \
    luarocks \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Build and install Neovim from source
RUN git clone --depth 1 --branch release-${NVIM_VERSION} https://github.com/neovim/neovim.git && \
    cd neovim && \
    make CMAKE_BUILD_TYPE=RelWithDebInfo && \
    make install && \
    chmod 755 /usr/local/bin/nvim && \
    cd .. && rm -rf neovim

# Create non-root user
RUN useradd -ms /bin/bash nvimuser
USER nvimuser
WORKDIR /home/nvimuser

# Setup Neovim config with lazy.nvim
# RUN git clone https://github.com/folke/lazy.nvim.git /home/nvimuser/.local/share/nvim/lazy/lazy.nvim
RUN git clone https://github.com/gaiwan-dev/neovim.git && cd neovim  && mkdir -p /home/nvimuser/.config/nvim && cp -r ./nvim /home/nvimuser/.config/

# Ensure ownership
RUN chown -R nvimuser:nvimuser /home/nvimuser

# Sync plugins
RUN nvim --headless "+Lazy! sync" +qa && \
    nvim --headless -c "lua require('nvim-treesitter.install').update({ with_sync = true })" +qa

RUN echo "HOME is $HOME" && nvim --version

# Run tests
RUN cd /home/nvimuser/.local/share/nvim/lazy/nvim-language-doc && ./run_tests.sh


CMD ["/bin/bash"]

