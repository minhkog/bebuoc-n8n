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

FROM ghcr.io/n8n-io/n8n:latest

# Chạy dưới quyền root để sao chép các công cụ từ container exec-files vào container chính
USER root

# Sao chép các công cụ từ container exec-files vào container chính
RUN echo $EXECUTE_FILES | tr ',' '\n' | while read package; do \
        if [ -f /usr/bin/$package ]; then \
            echo "$package found, copying to /usr/bin/..." && \
            cp /usr/bin/$package /usr/local/bin/ && \
            echo "$package copied successfully."; \
        else \
            echo "$package not found, skipping copy."; \
        fi \
    done

# Sao chép thư viện liên quan từ exec-files nếu cần, tránh đệ quy
RUN if [ -d /usr/lib ]; then \
        echo "Copying libraries from exec-files..." && \
        rsync -av --exclude='/usr/lib/lib' /usr/lib/ /usr/lib/; \
    else \
        echo "Libraries not found, skipping copy."; \
    fi

# Chuyển về người dùng 'node' để tiếp tục thực thi các lệnh
USER node

# Kiểm tra phiên bản của các công cụ
RUN echo "Checking ffmpeg version..." && ffmpeg -version || echo "ffmpeg not found"
RUN echo "Checking curl version..." && curl --version || echo "curl not found"
