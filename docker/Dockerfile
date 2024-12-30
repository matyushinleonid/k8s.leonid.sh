FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    gnupg \
    software-properties-common \
    curl \
    apt-transport-https \
    ca-certificates \
    lsb-release \
    ruby-full

# Install Terraform
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
        > /etc/apt/sources.list.d/hashicorp.list && \
        apt-get update && \
        apt-get install -y terraform

# Install Ansible
RUN apt-get install -y ansible

# Install Bashly
RUN gem install bashly

# Install Kubectl
RUN mkdir -p -m 755 /etc/apt/keyrings && \
        curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
        chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
        echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' > /etc/apt/sources.list.d/kubernetes.list && \
        chmod 644 /etc/apt/sources.list.d/kubernetes.list && \
        apt-get update && \
        apt-get install -y kubectl

# Install Helm
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

WORKDIR /root/k8s.leonid.sh

COPY setup_terraformrc.sh /usr/local/bin/setup_terraformrc.sh
RUN chmod +x /usr/local/bin/setup_terraformrc.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["sleep", "infinity"]
