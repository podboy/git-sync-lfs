ARG ALPINE_VERSION=latest
ARG GIT_SYNC_VERSION

FROM alpine:${ALPINE_VERSION} AS builder

RUN apk add --no-cache curl tar

ARG ARCH=amd64
ARG GIT_LFS_VERSION

RUN echo "Building for architecture: ${ARCH}" && \
    echo "GIT_LFS_VERSION: ${GIT_LFS_VERSION}" && \
    echo "Download URL: https://github.com/git-lfs/git-lfs/releases/download/${GIT_LFS_VERSION}/git-lfs-linux-${ARCH}-${GIT_LFS_VERSION}.tar.gz" && \
    curl -v -sSL -o /tmp/git-lfs.tar.gz "https://github.com/git-lfs/git-lfs/releases/download/${GIT_LFS_VERSION}/git-lfs-linux-${ARCH}-${GIT_LFS_VERSION}.tar.gz" && \
    ls -la /tmp/git-lfs.tar.gz && tar -xzf /tmp/git-lfs.tar.gz -C /tmp && \
    ls -la /tmp/ && mv /tmp/git-lfs-*/git-lfs /tmp/ && chmod +x /tmp/git-lfs

RUN /tmp/git-lfs --version

FROM registry.k8s.io/git-sync/git-sync:${GIT_SYNC_VERSION}

USER root

COPY --from=builder /tmp/git-lfs /usr/bin/git-lfs
COPY hooks/ /usr/share/git-core/templates/hooks/

RUN chown 755 /usr/share/git-core/templates/hooks/post-checkout && \
    chmod +x /usr/share/git-core/templates/hooks/post-checkout && \
    git lfs install --system && git lfs --version

USER 65533:65533

RUN git lfs version
