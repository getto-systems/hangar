FROM docker:stable

ENV DOCKLE_VERSION 0.2.0
ENV TRIVY_VERSION 0.1.6

RUN set -x && \
  apk --no-cache -Uuv add bash git curl tar sed grep && \
  : "fix vulnerabilities" && \
  apk --no-cache -Uuv add \
    openssl \
  && \
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
  :

COPY getto-hangar-*.sh /usr/local/bin/

CMD ["sh"]
