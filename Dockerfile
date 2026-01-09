# Tạo một container từ Python Alpine để cài đặt ffmpeg
FROM python:3.13-alpine AS python-extras

WORKDIR /extras
RUN echo "Install ffmpeg" && \
    apk add --no-cache ffmpeg

# Dùng image chính của n8n
FROM ghcr.io/n8n-io/n8n:latest

# Sao chép ffmpeg từ image python-extras vào container n8n
COPY --from=python-extras /usr/bin/ffmpeg /usr/bin/ffmpeg
COPY --from=python-extras /usr/lib /usr/lib

# Đảm bảo quyền và thông tin người dùng đúng
USER node
ENV N8N_USER_ID=0
ENV N8N_USER_GROUP=0

# Kiểm tra lại ffmpeg đã được cài đặt thành công
RUN ffmpeg -version
