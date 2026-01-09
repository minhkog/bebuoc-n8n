FROM python:3.13-alpine AS exec-files
WORKDIR /extras
ARG EXECUTE_FILE_PACKAGES="ffmpeg,curl"
ENV EXECUTE_FILE_PACKAGES=$EXECUTE_FILE_PACKAGES
RUN mkdir -p /EXECUTE_FILE_PACKAGES
RUN if [ -n "$EXECUTE_FILE_PACKAGES" ] && [ "$EXECUTE_FILE_PACKAGES" != "" ]; then \
        echo "Installing packages: $EXECUTE_FILE_PACKAGES" && \
        echo $EXECUTE_FILE_PACKAGES | tr ',' '\n' | while read package; do \
                echo "Installing $package..." && \
                apk add --no-cache $package || { echo "Failed to install $package"; exit 1; } && \
                cp /usr/bin/$package /EXECUTE_FILE_PACKAGES/$package; \
        done \
    else \
        echo "No packages to install."; \
    fi


FROM ghcr.io/n8n-io/n8n:latest
COPY --from=exec-files /EXECUTE_FILE_PACKAGES/* /usr/bin
COPY --from=exec-files /usr/lib /usr/lib

USER node
ARG EXECUTE_FILE_PACKAGES
RUN if [ -n "$EXECUTE_FILE_PACKAGES" ] && [ "$EXECUTE_FILE_PACKAGES" != "" ]; then \
        echo "Checking packages: $EXECUTE_FILE_PACKAGES" && \
        echo $EXECUTE_FILE_PACKAGES | tr ',' '\n' | while read package; do \
                if [ -f /usr/bin/$package ]; then \
                    echo "$package exists"; \
                else \
                    echo "ffmpeg does not exist"; \
                fi \
        done \
    else \
        echo "No packages to install."; \
    fi
