# https://hub.docker.com/_/almalinux
ARG VARIANT="8.10"
FROM almalinux:${VARIANT}

ARG USER_NAME
ARG USER_PASSWORD
ARG USER_UID
ARG USER_GID

ARG DOTNET_VERSION
ARG DOTNET_INSTALL_PATH="/usr/local/share/dotnet"

ARG VSCODE_VERSION="stable"
ARG VSCODE_INSTALL_PATH="/usr/local/bin"

RUN dnf update -y \
    && dnf install -y epel-release \
    && dnf install -y --enablerepo=epel \
        procps \
        sudo \
        git \
        openssh-server \
        supervisor \
        wget \
        libicu

# Entrypoint
COPY entrypoint.d /entrypoint.d
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh \
    && chmod +x -R /entrypoint.d

# Supervisor
COPY supervisord.conf /etc/supervisor/supervisord.conf
RUN mkdir -p /var/run/supervisor /var/log/supervisor \
    && chmod -R 755 /var/run/supervisor /var/log/supervisor

# SSH
RUN mkdir -p /etc/ssh/ssh_host_keys \
    && sed -i 's|HostKey /etc/ssh/|HostKey /etc/ssh/ssh_host_keys/|' /etc/ssh/sshd_config

# .NET SDK のインストール ※要 wget libicu
RUN wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh \
    && chmod +x ./dotnet-install.sh \
    && mkdir -p "${DOTNET_INSTALL_PATH}" \
    && ./dotnet-install.sh --version ${DOTNET_VERSION} --install-dir "${DOTNET_INSTALL_PATH}" \
    && rm ./dotnet-install.sh \
    && echo "export PATH=\$PATH:${DOTNET_INSTALL_PATH}" > /etc/profile.d/dotnet_path.sh

# VSCode CLI をインストール
RUN wget "https://code.visualstudio.com/sha/download?build=${VSCODE_VERSION}&os=cli-alpine-x64" -O vscode_cli.tar.gz \
    && tar -xf vscode_cli.tar.gz \
    && mv ./code "${VSCODE_INSTALL_PATH}" \
    && rm ./vscode_cli.tar.gz

# 一般ユーザー追加    
RUN groupadd --gid ${USER_GID} ${USER_NAME} \
    && useradd \
        --shell /bin/bash \
        --create-home \
        --home-dir /home/${USER_NAME} \
        --uid ${USER_UID} \
        --gid ${USER_GID} \
        ${USER_NAME} \
    && echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER_NAME} \
    && chmod 0440 /etc/sudoers.d/${USER_NAME} \
    && echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd

EXPOSE 22
ENTRYPOINT ["sudo", "/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}
