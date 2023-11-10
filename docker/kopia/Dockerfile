FROM --platform=$BUILDPLATFORM kopia/kopia:latest

# Init config & scripts
COPY app.orig /app.orig

# Install extra packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    gettext-base \
    mysql-client \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Update entrypoint
COPY docker-entrypoint-patched.sh /bin
ENTRYPOINT ["docker-entrypoint-patched.sh"]