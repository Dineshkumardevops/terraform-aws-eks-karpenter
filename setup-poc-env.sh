#!/bin/bash
set -e

# Detect OS
OS=$(awk -F= '/^NAME/{print $2}' /etc/os-release)

echo "Updating system packages..."
if [[ "$OS" == *"Amazon Linux"* ]]; then
  sudo yum update -y
  sudo yum install -y unzip curl wget git tar

  echo "Installing Docker..."
  sudo amazon-linux-extras enable docker
  sudo yum install -y docker
  sudo systemctl enable docker
  sudo systemctl start docker
  sudo usermod -aG docker ec2-user

  echo "Installing kubectl..."
  curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.0/2024-09-11/bin/linux/amd64/kubectl
  chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin/

  echo "Installing AWS CLI v2..."
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  rm -rf aws awscliv2.zip

elif [[ "$OS" == *"Ubuntu"* ]]; then
  sudo apt-get update -y
  sudo apt-get install -y unzip curl wget git docker.io

  echo "Starting Docker..."
  sudo systemctl enable docker
  sudo systemctl start docker
  sudo usermod -aG docker $USER

  echo "Installing kubectl..."
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin/

  echo "Installing AWS CLI v2..."
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  rm -rf aws awscliv2.zip
fi

echo "Installing eksctl..."
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_${PLATFORM}.tar.gz"
tar -xzf eksctl_${PLATFORM}.tar.gz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
rm eksctl_${PLATFORM}.tar.gz

echo "Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "Installing Karpenter CLI (karpenterctl)..."
curl -fsSL https://karpenter.sh/download/latest/karpenterctl-linux-amd64 -o karpenterctl
chmod +x karpenterctl
sudo mv karpenterctl /usr/local/bin/

echo "All tools installed successfully!"
echo "You may need to log out and log back in for docker group permissions to take effect."
