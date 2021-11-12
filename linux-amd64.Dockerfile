FROM golang:1.15-alpine3.12 as rclone-builder
ARG RCLONE_VERSION
RUN apk add --no-cache git build-base bash && \
    git clone -n https://github.com/rclone/rclone.git /rclone && cd /rclone && \
    git checkout v${RCLONE_VERSION} -b hotio && \
    make


FROM golang:1.15-alpine3.12 as gclone-builder
ARG GCLONE_VERSION
RUN apk add --no-cache git build-base bash && \
    git clone -n https://github.com/l3uddz/rclone.git /gclone && cd /gclone && \
    git checkout ${GCLONE_VERSION} -b hotio && \
    make


FROM golang:alpine as crop-builder
ARG VERSION
RUN apk add --no-cache git build-base bash && \
    git clone -n https://github.com/l3uddz/crop.git /crop && cd /crop && \
    git checkout v${VERSION} -b hotio && \
    make


FROM alpine@sha256:5e604d3358ab7b6b734402ce2e19ddd822a354dc14843f34d36c603521dbb4f9
ENTRYPOINT ["crop"]
COPY --from=rclone-builder /go/bin/rclone /usr/local/bin/rclone
COPY --from=gclone-builder /go/bin/rclone /usr/local/bin/gclone
COPY --from=crop-builder /crop/dist/crop_linux_amd64/crop /usr/local/bin/crop
RUN ln -s /usr/local/bin/gclone /usr/local/bin/lclone
