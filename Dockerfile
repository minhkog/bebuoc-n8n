FROM python:3.13-alpine AS python-extras
WORKDIR /extras
RUN echo "Install ffmpeg" && \
    apk add --no-cache ffmpeg

FROM ghcr.io/n8n-io/n8n:latest
COPY --from=python-extras /usr/bin/ffmpeg /bin/sh/ffmpeg

USER node
ENV N8N_USER_ID=0
ENV N8N_USER_GROUP=0
