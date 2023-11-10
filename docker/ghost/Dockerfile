FROM --platform=$BUILDPLATFORM ghost:latest

# Install extra packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    unzip \
    libarchive-tools \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Remove defalut themes & content,
RUN rm -rf $GHOST_INSTALL/content.orig

# Add prod config
COPY config.production.json $GHOST_INSTALL/config.production.json

# Prepare default content
COPY content.orig $GHOST_INSTALL/content.orig

# Install adapters dependencies
RUN npm install $GHOST_INSTALL/content.orig/adapters/storage/s3

# Download default themes. Uncomment the themes you would like to download in advance
RUN curl -s -L -o $GHOST_INSTALL/content.orig/themes/source.zip https://github.com/TryGhost/Source/archive/refs/heads/main.zip
RUN curl -s -L -o $GHOST_INSTALL/content.orig/themes/digest.zip https://github.com/TryGhost/Digest/archive/refs/heads/main.zip
# RUN curl -s -L -o $GHOST_INSTALL/content.orig/themes/taste.zip https://github.com/TryGhost/Taste/archive/refs/heads/main.zip
# RUN curl -s -L -o $GHOST_INSTALL/content.orig/themes/solo.zip https://github.com/TryGhost/Solo/archive/refs/heads/main.zip
# RUN curl -s -L -o $GHOST_INSTALL/content.orig/themes/headline.zip https://github.com/TryGhost/Headline/archive/refs/heads/main.zip
# RUN curl -s -L -o $GHOST_INSTALL/content.orig/themes/edition.zip https://github.com/TryGhost/Edition/archive/refs/heads/main.zip
# RUN curl -s -L -o $GHOST_INSTALL/content.orig/themes/alto.zip https://github.com/TryGhost/Alto/archive/refs/heads/main.zip
# RUN curl -s -L -o $GHOST_INSTALL/content.orig/themes/edge.zip https://github.com/TryGhost/Edge/archive/refs/heads/main.zip
# RUN curl -s -L -o $GHOST_INSTALL/content.orig/themes/dope.zip https://github.com/TryGhost/Dope/archive/refs/heads/main.zip
# RUN curl -s -L -o $GHOST_INSTALL/content.orig/themes/london.zip https://github.com/TryGhost/London/archive/refs/heads/main.zip
# RUN curl -s -L -o $GHOST_INSTALL/content.orig/themes/casper.zip https://github.com/TryGhost/Casper/archive/refs/heads/main.zip
# RUN curl -s -L -o $GHOST_INSTALL/content.orig/themes/episode.zip https://github.com/TryGhost/Episode/archive/refs/heads/main.zip
# RUN curl -s -L -o $GHOST_INSTALL/content.orig/themes/dawn.zip https://github.com/TryGhost/Dawn/archive/refs/heads/main.zip
# RUN curl -s -L -o $GHOST_INSTALL/content.orig/themes/wave.zip https://github.com/TryGhost/Wave/archive/refs/heads/main.zip
# RUN curl -s -L -o $GHOST_INSTALL/content.orig/themes/journal.zip https://github.com/TryGhost/Journal/archive/refs/heads/main.zip
# RUN curl -s -L -o $GHOST_INSTALL/content.orig/themes/bulletin.zip https://github.com/TryGhost/Bulletin/archive/refs/heads/main.zip
# RUN curl -s -L -o $GHOST_INSTALL/content.orig/themes/ease.zip https://github.com/TryGhost/Ease/archive/refs/heads/main.zip
# RUN curl -s -L -o $GHOST_INSTALL/content.orig/themes/ruby.zip https://github.com/TryGhost/Ruby/archive/refs/heads/main.zip
RUN curl -s -L -o $GHOST_INSTALL/content.orig/themes/liebling.zip https://github.com/eddiesigner/liebling/archive/refs/heads/master.zip
RUN curl -s -L -o $GHOST_INSTALL/content.orig/themes/attila.zip https://github.com/zutrinken/attila/archive/refs/heads/master.zip

# Unpack downloaded ZIPed themes
RUN find $GHOST_INSTALL/content.orig/themes -name '*.zip' -execdir sh -c 'mkdir "$(basename {} .zip)" && bsdtar --strip-components=1 -xvf {} -C "$(basename {} .zip)" && rm -f {}' \;
RUN chown node:node -R $GHOST_INSTALL/content.orig
RUN chmod -R 755 $GHOST_INSTALL/content.orig