FROM golang:1.23-alpine AS build
RUN apk update \
    && apk --no-cache add ca-certificates tzdata \
    && update-ca-certificates
ENV TZ="UTC"
# Don't run as root
RUN adduser -D -g '' thought
WORKDIR /home/thought
COPY go.mod go.sum ./
COPY *.go .
ARG VERSION
RUN CGO_ENABLED=0 go build -a -o bin \
    -ldflags "-exldflags '-static' -s -w" \
    -ldflags "-X main.version=${VERSION}"

FROM busybox:1.37-musl
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs
COPY --from=build /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=build /etc/passwd /etc/passwd
COPY --from=build /home/thought/bin /home/thought/bin
USER thought
WORKDIR /home/thought
EXPOSE 8080
ENTRYPOINT ["/home/thought/bin"]
