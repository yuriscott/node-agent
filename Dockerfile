FROM golang:1.23-bullseye AS builder
ARG TARGETOS
ARG TARGETARCH
RUN apt update && apt install -y libsystemd-dev
ENV GOPROXY="https://goproxy.cn"
WORKDIR /tmp/src
COPY go.mod .
COPY go.sum .
RUN go mod download
COPY . .
ARG VERSION=unknown
RUN CGO_ENABLED=1 GOOS=${TARGETOS:-linux} GOARCH=${TARGETARCH} go build -mod=readonly -ldflags "-X main.version=$VERSION" -o node-agent .

FROM registry.access.redhat.com/ubi9/ubi

ARG VERSION=unknown
LABEL name="node-agent" \
      vendor="Inc." \
      version=${VERSION} \
      summary="Node Agent."

COPY LICENSE /licenses/LICENSE

COPY --from=builder /tmp/src/node-agent /usr/bin/node-agent
ENTRYPOINT ["node-agent"]
