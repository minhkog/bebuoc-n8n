FROM jrottenberg/ffmpeg:8.0-alpine AS ffmpeg

RUN which ffmpeg

FROM ghcr.io/n8n-io/n8n:latest


USER node
ENV N8N_USER_ID=0
ENV N8N_USER_GROUP=0
