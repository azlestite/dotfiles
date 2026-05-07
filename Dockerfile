FROM ubuntu:24.04

ARG USERNAME=azlest
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV DEBIAN_FRONTEND=noninteractive
ENV CI=true
ENV LANG=en_US.UTF-8
ENV TZ=Asia/Tokyo

# RUN sed -i.bak -r 's@http://(jp\.)?archive\.ubuntu\.com/ubuntu/?@https://ftp.udx.icscoe.jp/Linux/ubuntu/@g' /etc/apt/sources.list.d/ubuntu.sources

# RUN sed -i.bak -r 's@http://(jp\.)?archive\.ubuntu\.com/ubuntu/?@http://jp.archive.ubuntu.com/ubuntu/@g' /etc/apt/sources.list.d/ubuntu.sources

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update && apt install -y --no-install-recommends \
  sudo \
  build-essential \
  curl \
  git \
  ca-certificates \
  openssh-client \
  gnupg \
  locales \
  tzdata \
  unzip \
  && apt clean \
  && rm -rf /var/lib/apt/lists/* \
  && locale-gen $LANG \
  && update-locale LANG=$LANG

RUN userdel -r ubuntu || true
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -G sudo -s /bin/bash \
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER $USERNAME
WORKDIR /home/$USERNAME

RUN mkdir -p .local/bin .local/src \
  && curl -fsSL "https://bitwarden.com/download/?app=cli&platform=linux" -o .local/src/bw-linux.zip \
  && unzip .local/src/bw-linux.zip -d .local/bin/ \
  && chmod +x .local/bin/bw \
  && rm -rf .local/src/bw-linux.zip

RUN sudo sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin

RUN mkdir -p ~/.local/share/fonts
# RUN mkdir -p /tmp
WORKDIR /home/$USERNAME/.local/share/chezmoi
