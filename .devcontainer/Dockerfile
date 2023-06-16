# Note: You can use any Debian/Ubuntu based image you want. 
FROM mcr.microsoft.com/devcontainers/base:bullseye

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends xdg-utils

# # Install conda
ENV CONDA_DIR /local/user/conda
RUN curl -o ./miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-$(uname -m).sh && \
    chmod +x ./miniconda.sh && \
    ./miniconda.sh -b -p ${CONDA_DIR} && \
    rm miniconda.sh
ENV PATH $CONDA_DIR/bin:$PATH
RUN chown -R vscode ${CONDA_DIR}

