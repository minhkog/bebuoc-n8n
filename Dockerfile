FROM ghcr.io/n8n-io/n8n:latest

USER root
RUN apk add --no-cache ffmpeg

USER node
ENV N8N_USER_ID=0
ENV N8N_USER_GROUP=0
