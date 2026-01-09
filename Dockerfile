FROM ghcr.io/n8n-io/n8n:latest

USER node
ENV N8N_USER_ID=0
ENV N8N_USER_GROUP=0

USER root
FROM jrottenberg/ffmpeg:4.4-alpine AS ffmpeg

FROM alpine:latest
COPY --from=ffmpeg / /

RUN ffmpeg -version
USER node
