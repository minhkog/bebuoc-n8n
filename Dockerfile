FROM python:3.13-alpine AS exec-files
WORKDIR /extras

ARG EXECUTE_FILES="ffmpeg,curl"
ENV EXECUTE_FILES=$EXECUTE_FILES

# Sử dụng echo và trích xuất các gói từ biến ENV, sau đó cài đặt
RUN echo $EXECUTE_FILES | tr ',' '\n' | while read package; do \
        apk add --no-cache $package; \
    done

FROM ghcr.io/n8n-io/n8n:latest
COPY --from=exec-files /usr/bin/ffmpeg /usr/bin/ffmpeg
COPY --from=exec-files /usr/bin/curl /usr/bin/curl
COPY --from=exec-files /usr/lib /usr/lib

USER node
RUN ffmpeg -version
RUN curl --version
