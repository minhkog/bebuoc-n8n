FROM python:3.13-alpine AS exec-files
WORKDIR /extras

ARG EXECUTE_FILES="ffmpeg,curl"
#ENV EXECUTE_FILES=$EXECUTE_FILES

# Tách EXECUTE_FILES thành các gói riêng biệt và cài đặt từng gói
RUN IFS=',' read -r -a packages <<< "$EXECUTE_FILES" && \
    for package in "${packages[@]}"; do \
        apk add --no-cache $package; \
    done

FROM ghcr.io/n8n-io/n8n:latest
COPY --from=exec-files /usr/bin/ffmpeg /usr/bin/ffmpeg
COPY --from=exec-files /usr/bin/curl /usr/bin/curl
COPY --from=exec-files /usr/lib /usr/lib

USER node
RUN ffmpeg -version
RUN curl --version
