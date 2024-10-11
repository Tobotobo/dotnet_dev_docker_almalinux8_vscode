# https://hub.docker.com/_/almalinux
ARG VARIANT="8.10"
FROM almalinux:${VARIANT}

RUN dnf update -y \
    && dnf install -y epel-release \
    && dnf install -y --enablerepo=epel \
        glibc-langpack-ja \
        glibc-locale-source \
        procps \
        sudo \
        git \
        openssh-server \
        supervisor \
        wget \
        zip \
        nano \ 
        htop

# ロケール及びタイムゾーンを日本に設定
RUN localedef -f UTF-8 -i ja_JP ja_JP.UTF-8 \
    && echo 'LANG=ja_JP.UTF-8' > /etc/locale.conf \
    && ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
ENV LANG="ja_JP.UTF-8" \
    LANGUAGE="ja_JP:ja" \
    LC_ALL="ja_JP.UTF-8" \
    TZ="Asia/Tokyo"

# 諸々の開発ツールのインストール先
ARG DEV_TOOLS_DIR="/opt/dev-tools"

# VSCode CLI をインストール
ARG VSCODE_VERSION="stable" \
    VSCODE_HOME="${DEV_TOOLS_DIR}/vscode"
ARG VSCODE_INSTALL_DIR="${VSCODE_HOME}/bin" \
    VSCODE_SERVER_DATA_DIR="${VSCODE_HOME}/server-data" \
    VSCODE_USER_DATA_DIR="${VSCODE_HOME}/user-data" \
    VSCODE_EXTENSIONS_DIR="${VSCODE_HOME}/extensions" \
    VSCODE_CLI_DATA_DIR="${VSCODE_HOME}/cli-data"
COPY vscode_install_extension.sh /
RUN mkdir -p "${VSCODE_INSTALL_DIR}" \
    && mkdir -p "${VSCODE_SERVER_DATA_DIR}" \
    && mkdir -p "${VSCODE_USER_DATA_DIR}" \
    && mkdir -p "${VSCODE_EXTENSIONS_DIR}" \
    && mkdir -p "${VSCODE_CLI_DATA_DIR}" \
    && wget "https://code.visualstudio.com/sha/download?build=${VSCODE_VERSION}&os=cli-alpine-x64" -O /tmp/vscode_cli.tar.gz \
    && tar -xf /tmp/vscode_cli.tar.gz -C /tmp \
    && mv /tmp/code "${VSCODE_INSTALL_DIR}" \
    && rm /tmp/vscode_cli.tar.gz \
    && chmod +x /vscode_install_extension.sh \
    && echo "export PATH=\$PATH:${VSCODE_INSTALL_DIR}" > /etc/profile.d/vscode_path.sh
COPY settings.json "${VSCODE_SERVER_DATA_DIR}/data/Machine/"

# ----------------------------------------------------------------------------------------------------

# .NET SDK のインストール ※要 libicu
ARG DOTNET_VERSION \
    DOTNET_HOME="${DEV_TOOLS_DIR}/dotnet"
RUN dnf install -y \
        libicu \ 
    && wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh \
    && chmod +x ./dotnet-install.sh \
    && mkdir -p "${DOTNET_HOME}" \
    && ./dotnet-install.sh --version ${DOTNET_VERSION} --install-dir "${DOTNET_HOME}" \
    && rm ./dotnet-install.sh \
    && echo "export PATH=\$PATH:${DOTNET_HOME}" > /etc/profile.d/dotnet_path.sh

# C# の拡張機能をインストール
RUN /vscode_install_extension.sh "${VSCODE_EXTENSIONS_DIR}" ms-dotnettools csharp 2.45.25 linux-x64
RUN /vscode_install_extension.sh "${VSCODE_EXTENSIONS_DIR}" ms-dotnettools vscode-dotnet-runtime 2.1.7

# ----------------------------------------------------------------------------------------------------

# 一般ユーザー追加 
ARG USER_NAME \
    USER_PASSWORD \
    USER_UID \
    USER_GID
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

# 追加したユーザーを諸々の開発ツールのインストール先のオーナーに設定
RUN chown -R ${USER_UID}:${USER_GID} "${DEV_TOOLS_DIR}" \
    && chmod -R 775 "${DEV_TOOLS_DIR}"

# Entrypoint
COPY entrypoint.d /entrypoint.d
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh \
    && chmod +x -R /entrypoint.d

# Supervisor
ENV VSCODE_USER="${USER_NAME}" \
    VSCODE_INSTALL_DIR="${VSCODE_INSTALL_DIR}" \
    VSCODE_SERVER_DATA_DIR="${VSCODE_SERVER_DATA_DIR}" \
    VSCODE_USER_DATA_DIR="${VSCODE_USER_DATA_DIR}" \
    VSCODE_EXTENSIONS_DIR="${VSCODE_EXTENSIONS_DIR}" \
    VSCODE_CLI_DATA_DIR="${VSCODE_CLI_DATA_DIR}"
COPY supervisord.conf /etc/supervisor/
RUN mkdir -p /var/run/supervisor /var/log/supervisor \
    && chmod -R 755 /var/run/supervisor /var/log/supervisor

# SSH
RUN mkdir -p /etc/ssh/ssh_host_keys \
    && sed -i 's|HostKey /etc/ssh/|HostKey /etc/ssh/ssh_host_keys/|' /etc/ssh/sshd_config

# 起動時の設定
EXPOSE 22
ENTRYPOINT ["sudo", "-E", "/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}
