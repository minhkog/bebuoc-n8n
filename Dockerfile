# Bước 1: Tạo image exec-files để cài đặt các công cụ như ffmpeg, curl
FROM python:3.13-alpine AS exec-files
WORKDIR /extras

# Biến môi trường chứa các gói cần cài đặt
ARG EXECUTE_FILES="ffmpeg,curl"
ENV EXECUTE_FILES=$EXECUTE_FILES

# Cài đặt các gói từ biến EXECUTE_FILES
RUN mkdir -p /execute_files; && \
    if [ -n "$EXECUTE_FILES" ] && [ "$EXECUTE_FILES" != "" ]; then \
        echo "Installing packages: $EXECUTE_FILES" && \
        echo $EXECUTE_FILES | tr ',' '\n' | while read package; do \
                echo "Installing $package..." && \
                apk add --no-cache $package || { echo "Failed to install $package"; exit 1; } && \
                cp /usr/bin/$package /execute_files/; \
        done; \
    else \
        echo "No packages to install."; \
    fi

# Bước 2: Sử dụng image n8n chính
FROM ghcr.io/n8n-io/n8n:latest

COPY --from=exec-files /execute_files/* /usr/bin
COPY --from=exec-files /usr/lib /usr/lib

USER node

RUN echo "Checking ffmpeg version..." && ffmpeg -version || echo "ffmpeg not found"
RUN echo "Checking curl version..." && curl --version || echo "curl not found"
