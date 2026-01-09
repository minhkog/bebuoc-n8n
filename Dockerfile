FROM python:3.13-alpine AS exec-files
WORKDIR /extras

# Biến môi trường chứa các gói cần cài đặt
ARG EXECUTE_FILES="ffmpeg,curl"
ENV EXECUTE_FILES=$EXECUTE_FILES

# Kiểm tra và cài đặt các gói từ biến EXECUTE_FILES
RUN if [ -n "$EXECUTE_FILES" ] && [ "$EXECUTE_FILES" != "" ]; then \
        echo "Installing packages: $EXECUTE_FILES" && \
        echo $EXECUTE_FILES | tr ',' '\n' | while read package; do \
                echo "Installing $package..." && \
                apk add --no-cache $package || { echo "Failed to install $package"; exit 1; }; \
        done \
    else \
        echo "No packages to install."; \
    fi

FROM ghcr.io/n8n-io/n8n:latest

# Sao chép các công cụ từ container exec-files vào container chính
COPY --from=exec-files /usr/bin/ffmpeg /usr/bin/ffmpeg
COPY --from=exec-files /usr/bin/curl /usr/bin/curl
COPY --from=exec-files /usr/lib /usr/lib

USER node

# Kiểm tra phiên bản của ffmpeg và curl
RUN echo "Checking ffmpeg version..." && ffmpeg -version || echo "ffmpeg not found"
RUN echo "Checking curl version..." && curl --version || echo "curl not found"
