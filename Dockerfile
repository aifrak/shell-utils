FROM shellspec/shellspec-scratch:0.28.1 as shellspec
FROM koalaman/shellcheck:v0.7.2 as shellcheck
FROM mvdan/shfmt:v3.3.0 as shfmt
FROM hadolint/hadolint:v2.4.1 as hadolint

FROM node:16.3.0-buster as node
RUN npm install -g npm@7.17.0 --quiet

FROM ubuntu:groovy-20210524 as base

ENV LANG=C.UTF-8

USER root

ENV USERNAME=app-user
ARG GROUPNAME=${USERNAME}
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
ENV HOME=/home/${USERNAME}
ENV APP_DIR=/app

# Add user and project directory
RUN \
  groupadd --gid ${USER_GID} ${GROUPNAME} \
  && useradd --uid ${USER_UID} --gid ${USER_GID} --shell /bin/bash \
    --create-home ${USERNAME} \
  && mkdir ${APP_DIR} \
  && chown ${USER_GID}:${USER_GID} ${APP_DIR}

# Add shellspec
ENV PATH=/opt/shellspec:$PATH
COPY --from=shellspec --chown=root /opt/shellspec /opt/shellspec/

# Add shellcheck
COPY --from=shellcheck --chown=root /bin/shellcheck /usr/local/bin/

# Add shfmt
COPY --from=shfmt --chown=root /bin/shfmt /usr/local/bin/

# Add hadolint
COPY --from=hadolint --chown=root /bin/hadolint /usr/local/bin/

# Add NodeJS (without yarn)
COPY --from=node --chown=root /usr/local/bin /usr/local/bin/
COPY --from=node --chown=root /usr/local/include /usr/local/include/
COPY --from=node --chown=root /usr/local/lib /usr/local/lib/
COPY --from=node --chown=root /usr/local/share /usr/local/share/
# Remove dead symbolic links from yarn
RUN find /usr/local/bin/. -xtype l -exec rm {} \; 2>/dev/null

USER ${USERNAME}

WORKDIR ${APP_DIR}

# Install project packages
COPY --chown=${USERNAME} package-lock.json package.json .npmrc ./
RUN set -e \
  && npm ci --quiet \
  && touch node_modules/.gitkeep

CMD [ "bash" ]

FROM base as dev

USER root

RUN set -e \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update -qq \
  && apt-get install -y -qq --no-install-recommends ca-certificates=* git=* sudo=* \
  && echo "${USERNAME}" ALL=\(root\) NOPASSWD:ALL >/etc/sudoers.d/"${USERNAME}" \
  && chmod 0440 /etc/sudoers.d/"${USERNAME}" \
  && apt-get clean \
  && apt-get autoremove \
  && rm -rf /var/lib/apt/lists/*

USER ${USERNAME}

FROM dev as vscode

WORKDIR ${HOME}

RUN set -e \
  && mkdir -p .vscode-server/extensions \
    .vscode-server-insiders/extensions \
  && chown -R "${USERNAME}" \
    .vscode-server \
    .vscode-server-insiders

WORKDIR ${APP_DIR}
