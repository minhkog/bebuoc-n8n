# Bước 1: Tạo image exec-files để cài đặt các công cụ như ffmpeg, curl
FROM python:3.13-alpine AS exec-files
WORKDIR /extras

# Biến môi trường chứa các gói cần cài đặt (có thể thêm các gói khác vào đây)
ARG EXECUTE_FILES="ffmpeg,curl,git"  # Đây là danh sách công cụ cần cài đặt (có thể thay đổi)
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

# Lặp qua danh sách EXECUTE_FILES và sao chép các công cụ tương ứng từ container exec-files vào container chính
RUN echo $EXECUTE_FILES | tr ',' '\n' | while read package; do \
        if [ -f /usr/bin/$package ]; then \
            echo "$package found, copying to /usr/bin/..." && \
            cp /usr/bin/$package /usr/local/bin/ && \
            echo "$package copied successfully."; \
        else \
            echo "$package not found, skipping copy."; \
        fi \
    done

# Sao chép thư viện liên quan từ exec-files nếu cần
RUN if [ -d /usr/lib ]; then \
        echo "Copying libraries from exec-files..." && \
        cp -r /usr/lib /usr/lib; \
    else \
        echo "Libraries not found, skipping copy."; \
    fi

# Đảm bảo quyền người dùng là 'node'
USER node

# Kiểm tra phiên bản của các công cụ
RUN echo "Checking ffmpeg version..." && ffmpeg -version || echo "ffmpeg not found"
RUN echo "Checking curl version..." && curl --version || echo "curl not found"
RUN echo "Checking git version..." && git --version || echo "git not found"
