# This is an image containing all the tools needed (Terraform, Anslible, Cloudflared) to build and deploy this project.

FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=nonintercative

# Install common packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    gnupg \
    openssh-client \
    software-properties-common

# Register Terraform repository
RUN wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    tee /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/hashicorp.list

# Register Ansible repository
RUN add-apt-repository --yes --update ppa:ansible/ansible

# Register Cloudflared repository
RUN mkdir -p --mode=0755 /usr/share/keyrings && \
    curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] \
    https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/cloudflared.list

# Register Docker repo
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install build tools: Ansible, Terraform, Docker
RUN apt-get update && apt-get install -y --no-install-recommends \
    terraform \
    ansible \
    cloudflared \
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

RUN ansible-galaxy collection install community.docker

# Clean lists
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /project
WORKDIR /project

VOLUME [ "/project" ]

ENTRYPOINT [ "/project/build.sh" ]