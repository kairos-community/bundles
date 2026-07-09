FROM alpine as build
# renovate: datasource=github-releases depName=argoproj/argo-cd
ENV VERSION=v3.4.5
ARG TARGETARCH
RUN if [[ "$TARGETARCH" = "amd64" ]]; then \
      export CHECKSUM=a683ed902e3b7cdfd2b50d7a82b93ce00883064bca58418cace5e643ba755769; \
    elif [[ "$TARGETARCH" = "arm64" ]]; then \
      export CHECKSUM=b1822e83104e6d5a3d053eb7dcc3c261a7bd98c30f964440bceec3006be91abc; \
    fi && \
      echo "CHECKSUM=${CHECKSUM}" > /tmp/checksum_env
RUN source /tmp/checksum_env && echo "CHECKSUM is: ${CHECKSUM}"
ADD "https://github.com/argoproj/argo-cd/releases/download/${VERSION}/argocd-linux-${TARGETARCH}" /tmp
RUN DOWNLOAD_FILE="/tmp/argocd-linux-${TARGETARCH}" && \
    DOWNLOAD_CHECKSUM=$(sha256sum "${DOWNLOAD_FILE}" | awk '{print $1}') && \
    if [[ ${DOWNLOAD_CHECKSUM} != ${CHECKSUM} ]]; then \
      echo "Checksum does not match"; \
      exit 1; \
    fi

FROM --platform=$BUILDPLATFORM scratch
ARG TARGETARCH
COPY ./run.sh /
COPY --from=build /tmp/argocd-linux-${TARGETARCH} .
COPY ./assets /assets
