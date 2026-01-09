FROM jrottenberg/ffmpeg:4.4-alpine AS ffmpeg

FROM ghcr.io/n8n-io/n8n:latest
# Sao chép FFmpeg binary và thư viện cần thiết
COPY --from=ffmpeg /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg
COPY --from=ffmpeg /usr/local/lib /usr/local/lib

RUN ffmpeg -version
USER node
ENV N8N_USER_ID=0
ENV N8N_USER_GROUP=0
