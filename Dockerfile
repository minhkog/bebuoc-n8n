# Bước 1: Tạo image exec-files để cài đặt các công cụ như ffmpeg, curl
FROM python:3.13-alpine AS exec-files
WORKDIR /extras

# Biến môi trường chứa các gói cần cài đặt
ARG EXECUTE_FILES="ffmpeg,curl"
ENV EXECUTE_FILES=$EXECUTE_FILES

# Cài đặt các gói từ biến EXECUTE_FILES
RUN if [ -n "$EXECUTE_FILES" ] && [ "$EXECUTE_FILES" != "" ]; then \
        echo "Installing packages: $EXECUTE_FILES" && \
        echo $EXECUTE_FILES | tr ',' '\n' | while read package; do \
                echo "Installing $package..." && \
                apk add --no-cache $package || { echo "Failed to install $package"; exit 1; }; \
        done \
    else \
        echo "No packages to install."; \
    fi

# Bước 2: Sử dụng image n8n chính
FROM ghcr.io/n8n-io/n8n:latest

# Sao chép các công cụ từ container exec-files vào container chính
COPY --from=exec-files /usr/bin/ffmpeg /usr/bin/ffmpeg
COPY --from=exec-files /usr/bin/curl /usr/bin/curl

# Sao chép thư viện liên quan từ exec-files nếu cần (với quyền root)
RUN echo "Copying libraries from exec-files..." && \
    COPY --from=exec-files /usr/lib /usr/lib

# Đảm bảo quyền người dùng là 'node'
USER node

# Kiểm tra phiên bản của các công cụ
RUN echo "Checking ffmpeg version..." && ffmpeg -version || echo "ffmpeg not found"
RUN echo "Checking curl version..." && curl --version || echo "curl not found"
