FROM jrottenberg/ffmpeg:4.4-alpine AS ffmpeg

FROM ghcr.io/n8n-io/n8n:latest

COPY --from=ffmpeg / /opt/ffmpeg

RUN /opt/ffmpeg/usr/local/bin/ffmpeg -version
USER node
ENV N8N_USER_ID=0
ENV N8N_USER_GROUP=0
