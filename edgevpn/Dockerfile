FROM alpine AS build
# renovate: datasource=github-releases depName=mudler/edgevpn
ENV VERSION=0.35.3
ARG TARGETARCH

RUN if [[ "$TARGETARCH" = "amd64" ]]; then \
      export CHECKSUM=0e161225e77357e0c047d5ce12009f3b1fb9e1e825b2d6f61d4d99afb40b9e0d; \
      export ARCH=x86_64; \
    elif [[ "$TARGETARCH" = "arm64" ]]; then \
      export CHECKSUM=a71d20bd140d2b433ac0d098b83277893c3d3e77f4a658cc0ae663de6cbf8816; \
      export ARCH=arm64; \
    fi && \
      echo "CHECKSUM=${CHECKSUM}" >> /tmp/edgevpn_env && \
      echo "ARCH=${ARCH}" >> /tmp/edgevpn_env

RUN source /tmp/edgevpn_env; \
  echo "CHECKSUM is: ${CHECKSUM}"; \
  echo "ARCH is: ${ARCH}"; \
  wget -O "/tmp/edgevpn-v${VERSION}-Linux-${ARCH}.tar.gz" "https://github.com/mudler/edgevpn/releases/download/v${VERSION}/edgevpn-v${VERSION}-Linux-${ARCH}.tar.gz"; \
  DOWNLOAD_FILE="/tmp/edgevpn-v${VERSION}-Linux-${ARCH}.tar.gz"; \
  DOWNLOAD_CHECKSUM=$(sha256sum "${DOWNLOAD_FILE}" | awk '{print $1}'); \
  if [[ ${DOWNLOAD_CHECKSUM} != ${CHECKSUM} ]]; then \
    echo "Checksum does not match"; \
    exit 1; \
  fi; \
  tar -xzf "${DOWNLOAD_FILE}" -C /tmp; \
  chmod +x /tmp/edgevpn;

FROM --platform=$BUILDPLATFORM scratch
COPY ./run.sh /
COPY --from=build /tmp/edgevpn .
COPY ./assets /assets