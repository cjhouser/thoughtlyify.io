FROM mcr.microsoft.com/devcontainers/base:alpine-3.20 AS terraform
ENV PLATFORM=linux
ENV ARCH=amd64
ENV VERSION=1.12.2
WORKDIR /tmp
RUN apk add --update --virtual .deps --no-cache gnupg
RUN wget https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_${PLATFORM}_${ARCH}.zip
RUN wget https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_SHA256SUMS
RUN wget https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_SHA256SUMS.sig
RUN wget -qO- https://www.hashicorp.com/.well-known/pgp-key.txt | gpg --import
RUN gpg --verify terraform_${VERSION}_SHA256SUMS.sig terraform_${VERSION}_SHA256SUMS
RUN grep terraform_${VERSION}_${PLATFORM}_${ARCH}.zip terraform_${VERSION}_SHA256SUMS | sha256sum -c
RUN unzip terraform_${VERSION}_${PLATFORM}_${ARCH}.zip

FROM mcr.microsoft.com/devcontainers/base:alpine-3.20 AS go
ENV PLATFORM=linux
ENV ARCH=amd64
ENV VERSION=1.24.0
WORKDIR /tmp
RUN wget https://go.dev/dl/go${VERSION}.${PLATFORM}-${ARCH}.tar.gz
RUN tar -xzf go${VERSION}.${PLATFORM}-${ARCH}.tar.gz

FROM mcr.microsoft.com/devcontainers/base:alpine-3.20 AS flyctl
ENV PLATFORM=Linux
ENV ARCH=x86_64
ENV VERSION=0.3.145
WORKDIR /tmp
RUN wget https://github.com/superfly/flyctl/releases/download/v${VERSION}/flyctl_${VERSION}_${PLATFORM}_${ARCH}.tar.gz
RUN tar -xzf flyctl_${VERSION}_${PLATFORM}_${ARCH}.tar.gz

FROM mcr.microsoft.com/devcontainers/base:alpine-3.20 AS kubectl
ENV PLATFORM=linux
ENV ARCH=amd64
ENV VERSION=1.33.0
WORKDIR /tmp
RUN wget https://dl.k8s.io/release/v${VERSION}/bin/${PLATFORM}/${ARCH}/kubectl
RUN wget https://dl.k8s.io/release/v${VERSION}/bin/${PLATFORM}/${ARCH}/kubectl.sha256
RUN echo "$(cat kubectl.sha256) kubectl" | sha256sum --check
RUN chmod 755 kubectl

FROM mcr.microsoft.com/devcontainers/base:alpine-3.20 AS final
COPY --from=terraform /tmp/terraform /usr/local/bin/tf
COPY --from=flyctl /tmp/flyctl /usr/local/bin/fly
COPY --from=go /tmp/go/ /usr/local/go/
COPY --from=kubectl /tmp/kubectl /usr/local/bin/kubectl
ENV PATH=${PATH}:/usr/local/go/bin
RUN apk add --no-cache aws-cli
