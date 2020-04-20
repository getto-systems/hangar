FROM debian:buster

ENV DOCKLE_VERSION 0.2.4
ENV TRIVY_VERSION 0.6.0

RUN set -x && \
  apt-get update && \
  apt-get install -y apt-utils && \
  apt-get install -y \
    ca-certificates \
    curl \
    git \
  && \
  : "to fix vulnerabilities, update packages : 2020-04-08 : 1" && \
  apt-get install -y --no-install-recommends \
    libgnutls30 \
  && \
  : "install docker" && \
  curl -sSL https://get.docker.com | sh && \
  : "install dockle" && \
  mkdir -p /opt && \
  curl -L -o /opt/dockle.tar.gz https://github.com/goodwithtech/dockle/releases/download/v${DOCKLE_VERSION}/dockle_${DOCKLE_VERSION}_Linux-64bit.tar.gz && \
  tar zxvf /opt/dockle.tar.gz -C /opt && \
  mv /opt/dockle /usr/bin && \
  : "install trivy" && \
  curl -L -o /opt/trivy.tar.gz https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz && \
  tar zxvf /opt/trivy.tar.gz -C /opt && \
  mv /opt/trivy /usr/bin && \
  : "remove downloads" && \
  rm -rf /opt && \
  : "cleanup apt caches" && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  :

COPY getto-hangar-*.sh /usr/local/bin/

CMD ["sh"]
