FROM python:3.11.14-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-lc"]

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    curl \
    wget \
    bash \
    vim \
    build-essential \
    python3-pip \
    # Server system dependencies
    libglu1-mesa \
    libgl1 \
    libegl1 \
    libxrandr2 \
    libxinerama1 \
    libxcursor1 \
    libxi6 \
    libxext6 \
    libx11-6 \
    && rm -rf /var/lib/apt/lists/*


# Make python3/pip default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# --- Install uv (Astral) ---
# Installs to ~/.local/bin; we add it to PATH.
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /lehome
RUN git clone https://github.com/lehome-official/lehome-challenge.git
WORKDIR /lehome/lehome-challenge

RUN uv sync

RUN cd third_party && \
    git clone https://github.com/lehome-official/IsaacLab.git

RUN uv pip install -e ./source/lehome

RUN echo "source .venv/bin/activate" >> /root/.bashrc
CMD ["/bin/bash"]
