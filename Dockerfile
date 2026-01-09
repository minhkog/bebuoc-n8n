FROM jrottenberg/ffmpeg:8.0-alpine AS ffmpeg

FROM ghcr.io/n8n-io/n8n:latest

COPY --from=ffmpeg /usr/bin/ffmpeg /usr/bin/ffmpeg
COPY --from=ffmpeg /usr/lib /usr/lib
USER node
ENV N8N_USER_ID=0
ENV N8N_USER_GROUP=0
