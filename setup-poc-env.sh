#!/bin/bash
set -euo pipefail

echo "Detected OS: Amazon Linux"

# ---------------------------
# Update system and install basics
# ---------------------------
sudo dnf update -y
sudo dnf install -y unzip wget git tar dnf-plugins-core

# ---------------------------
# Docker installation
# ---------------------------
sudo dnf install -y docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user

# ---------------------------
# AWS CLI v2
# ---------------------------
if ! command -v aws &> /dev/null; then
    echo "Installing AWS CLI v2..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip
else
    echo "AWS CLI already installed"
fi

# ---------------------------
# kubectl
# ---------------------------
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
if ! command -v kubectl &> /dev/null || [[ "$(kubectl version --client --short 2>/dev/null | awk '{print $3}')" != "$KUBECTL_VERSION" ]]; then
    echo "Installing kubectl $KUBECTL_VERSION..."
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
else
    echo "kubectl already installed"
fi

# ---------------------------
# Terraform
# ---------------------------
TF_VER="1.6.4"
if ! command -v terraform &> /dev/null || [[ "$(terraform version -json | jq -r .terraform_version)" != "$TF_VER" ]]; then
    echo "Installing Terraform ${TF_VER}..."
    wget https://releases.hashicorp.com/terraform/${TF_VER}/terraform_${TF_VER}_linux_amd64.zip
    unzip terraform_${TF_VER}_linux_amd64.zip
    chmod +x terraform
    sudo mv terraform /usr/local/bin/
    rm terraform_${TF_VER}_linux_amd64.zip
else
    echo "Terraform ${TF_VER} already installed"
fi

# ---------------------------
# Helm
# ---------------------------
HELM_VER="v3.17.4"
if ! command -v helm &> /dev/null; then
    echo "Installing Helm ${HELM_VER}..."
    curl -LO https://get.helm.sh/helm-${HELM_VER}-linux-amd64.tar.gz
    tar -zxvf helm-${HELM_VER}-linux-amd64.tar.gz
    chmod +x linux-amd64/helm
    sudo mv linux-amd64/helm /usr/local/bin/
    rm -rf linux-amd64 helm-${HELM_VER}-linux-amd64.tar.gz
else
    echo "Helm already installed"
fi

# ---------------------------
# eksctl
# ---------------------------
if ! command -v eksctl &> /dev/null; then
    echo "Installing eksctl..."
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/eksctl /usr/local/bin/
else
    echo "eksctl already installed"
fi

echo "✅ All tools installed successfully!"
echo "Please log out and back in for Docker group permissions to take effect."
