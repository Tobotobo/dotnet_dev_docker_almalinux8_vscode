# https://hub.docker.com/_/almalinux
ARG VARIANT="8.10"
FROM almalinux:${VARIANT}

RUN dnf update -y \
    && dnf install -y epel-release \
    && dnf install -y --enablerepo=epel \
        procps \
        sudo \
        git \
        openssh-server \
        supervisor \
        wget \
        zip \
        nano \ 
        htop

# VSCode CLI をインストール
ARG VSCODE_VERSION="stable"
ARG VSCODE_INSTALL_PATH="/usr/local/bin"
ARG VSCODE_DATA_PATH="/vscode"
ARG VSCODE_SERVER_DATA_PATH="${VSCODE_DATA_PATH}/server-data"
ARG VSCODE_USER_DATA_PATH="${VSCODE_DATA_PATH}/user-data"
ARG VSCODE_EXTENSIONS_PATH="${VSCODE_DATA_PATH}/extensions"
ARG VSCODE_CLI_DATA_PATH="${VSCODE_DATA_PATH}/cli-data"
RUN wget "https://code.visualstudio.com/sha/download?build=${VSCODE_VERSION}&os=cli-alpine-x64" -O vscode_cli.tar.gz \
    && tar -xf vscode_cli.tar.gz \
    && mv ./code "${VSCODE_INSTALL_PATH}" \
    && rm ./vscode_cli.tar.gz \
    && mkdir -p "${VSCODE_SERVER_DATA_PATH}" \
    && mkdir -p "${VSCODE_USER_DATA_PATH}" \
    && mkdir -p "${VSCODE_EXTENSIONS_PATH}" \
    && mkdir -p "${VSCODE_CLI_DATA_PATH}"
COPY settings.json "${VSCODE_SERVER_DATA_PATH}/data/Machine/"
COPY vscode_install_extension.sh /
RUN chmod +x /vscode_install_extension.sh

# ----------------------------------------------------------------------------------------------------

# .NET SDK のインストール ※要 libicu
ARG DOTNET_VERSION
ARG DOTNET_INSTALL_PATH="/usr/local/share/dotnet"
RUN dnf install -y \
    libicu 
RUN wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh \
    && chmod +x ./dotnet-install.sh \
    && mkdir -p "${DOTNET_INSTALL_PATH}" \
    && ./dotnet-install.sh --version ${DOTNET_VERSION} --install-dir "${DOTNET_INSTALL_PATH}" \
    && rm ./dotnet-install.sh \
    && echo "export PATH=\$PATH:${DOTNET_INSTALL_PATH}" > /etc/profile.d/dotnet_path.sh

# C# の拡張機能をインストール
RUN /vscode_install_extension.sh "${VSCODE_EXTENSIONS_PATH}" ms-dotnettools csharp 2.45.25 linux-x64
RUN /vscode_install_extension.sh "${VSCODE_EXTENSIONS_PATH}" ms-dotnettools vscode-dotnet-runtime 2.1.7

# # ms-dotnettools.csharp-2.45.25
# RUN rm -f /tmp/vspackage.gzip && rm -f /tmp/vspackage.zip && rm -rf /tmp/vspackage \
#     && wget "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-dotnettools/vsextensions/csharp/2.45.25/vspackage?targetPlatform=linux-x64" -O /tmp/vspackage.gzip \
#     && gunzip -c /tmp/vspackage.gzip > /tmp/vspackage.zip \
#     && unzip /tmp/vspackage.zip "extension/*" -d /tmp/vspackage \
#     && mv /tmp/vspackage/extension /vscode/extensions/ms-dotnettools.csharp-2.45.25-linux-x64 \
#     && rm -f /tmp/vspackage.gzip && rm -f /tmp/vspackage.zip && rm -rf /tmp/vspackage

# # ms-dotnettools.vscode-dotnet-runtime-2.1.7
# RUN rm -f /tmp/vspackage.gzip && rm -f /tmp/vspackage.zip && rm -rf /tmp/vspackage \
#     && wget "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-dotnettools/vsextensions/vscode-dotnet-runtime/2.1.7/vspackage" -O /tmp/vspackage.gzip \
#     && gunzip -c /tmp/vspackage.gzip > /tmp/vspackage.zip \
#     && unzip /tmp/vspackage.zip "extension/*" -d /tmp/vspackage \
#     && mv /tmp/vspackage/extension /vscode/extensions/ms-dotnettools.vscode-dotnet-runtime-2.1.7-linux-x64 \
#     && rm -f /tmp/vspackage.gzip && rm -f /tmp/vspackage.zip && rm -rf /tmp/vspackage

# ----------------------------------------------------------------------------------------------------

# VSCode のデータの保存先にアクセス許可を設定 ※TODO: どう設定するのが適切？
RUN chmod -R 777 "${VSCODE_DATA_PATH}"

# Entrypoint
COPY entrypoint.d /entrypoint.d
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh \
    && chmod +x -R /entrypoint.d

# Supervisor
COPY supervisord.conf /etc/supervisor/
RUN mkdir -p /var/run/supervisor /var/log/supervisor \
    && chmod -R 755 /var/run/supervisor /var/log/supervisor

# SSH
RUN mkdir -p /etc/ssh/ssh_host_keys \
    && sed -i 's|HostKey /etc/ssh/|HostKey /etc/ssh/ssh_host_keys/|' /etc/ssh/sshd_config

# 一般ユーザー追加 
ARG USER_NAME
ARG USER_PASSWORD
ARG USER_UID
ARG USER_GID
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
ENTRYPOINT ["sudo", "-E", "/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}
