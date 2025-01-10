#!/bin/bash

# Function to prompt user for version selection
prompt_version() {
    local component=$1
    local default_version=$2
    local latest_version=$3
    local selected_version

    echo "Select version for $component:"
    echo "1) Default version: $default_version"
    echo "2) Latest version: $latest_version"
    read -p "Enter choice [1 or 2]: " choice

    case $choice in
        1)
            selected_version=$default_version
            ;;
        2)
            selected_version=$latest_version
            ;;
        *)
            echo "Invalid choice. Using default version: $default_version"
            selected_version=$default_version
            ;;
    esac

    echo $selected_version
}

# Update package list
sudo apt-get update

# Install curl and sudo
sudo apt-get install -y curl sudo

# Install Docker
sudo apt-get install -y ca-certificates
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install conntrack
sudo apt-get install -y conntrack

# Install crictl
DEFAULT_CRICTL_VERSION="v1.26.0"
LATEST_CRICTL_VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/cri-tools/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
CRICTL_VERSION=$(prompt_version "crictl" $DEFAULT_CRICTL_VERSION $LATEST_CRICTL_VERSION)
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$CRICTL_VERSION/crictl-$CRICTL_VERSION-linux-amd64.tar.gz
sudo tar zxvf crictl-$CRICTL_VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm crictl-$CRICTL_VERSION-linux-amd64.tar.gz

# Install cri-dockerd
DEFAULT_CRIDOCKERD_VERSION="v0.3.16"
LATEST_CRIDOCKERD_VERSION=$(curl -s https://api.github.com/repos/Mirantis/cri-dockerd/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
CRIDOCKERD_VERSION=$(prompt_version "cri-dockerd" $DEFAULT_CRIDOCKERD_VERSION $LATEST_CRIDOCKERD_VERSION)
wget https://github.com/Mirantis/cri-dockerd/releases/download/$CRIDOCKERD_VERSION/cri-dockerd_${CRIDOCKERD_VERSION#v}.3-0.debian-bookworm_amd64.deb
sudo dpkg -i cri-dockerd_${CRIDOCKERD_VERSION#v}.3-0.debian-bookworm_amd64.deb
rm cri-dockerd_${CRIDOCKERD_VERSION#v}.3-0.debian-bookworm_amd64.deb

# Install CNI plugins
DEFAULT_CNI_PLUGIN_VERSION="v1.6.2"
LATEST_CNI_PLUGIN_VERSION=$(curl -s https://api.github.com/repos/containernetworking/plugins/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
CNI_PLUGIN_VERSION=$(prompt_version "CNI plugins" $DEFAULT_CNI_PLUGIN_VERSION $LATEST_CNI_PLUGIN_VERSION)
CNI_PLUGIN_TAR="cni-plugins-linux-amd64-$CNI_PLUGIN_VERSION.tgz"
CNI_PLUGIN_INSTALL_DIR="/opt/cni/bin"
curl -LO "https://github.com/containernetworking/plugins/releases/download/$CNI_PLUGIN_VERSION/$CNI_PLUGIN_TAR"
sudo mkdir -p "$CNI_PLUGIN_INSTALL_DIR"
sudo tar -xf "$CNI_PLUGIN_TAR" -C "$CNI_PLUGIN_INSTALL_DIR"
rm "$CNI_PLUGIN_TAR"

# Install kubectl
LATEST_KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/$LATEST_KUBECTL_VERSION/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# Install Minikube
DEFAULT_MINIKUBE_VERSION="v1.33.0"
LATEST_MINIKUBE_VERSION=$(curl -s https://api.github.com/repos/kubernetes/minikube/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
MINIKUBE_VERSION=$(prompt_version "Minikube" $DEFAULT_MINIKUBE_VERSION $LATEST_MINIKUBE_VERSION)
curl -LO https://github.com/kubernetes/minikube/releases/download/$MINIKUBE_VERSION/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

# Start Minikube
sudo minikube start --driver=none

# Install AWX Operator
DEFAULT_AWX_OPERATOR_VERSION="2.19.1"
LATEST_AWX_OPERATOR_VERSION=$(curl -s https://api.github.com/repos/ansible/awx-operator/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
AWX_OPERATOR_VERSION=$(prompt_version "AWX Operator" $DEFAULT_AWX_OPERATOR_VERSION $LATEST_AWX_OPERATOR_VERSION)
git clone https://github.com/ansible/awx-operator
cd awx-operator
git fetch --tags
git checkout tags/$AWX_OPERATOR_VERSION

# Create kustomization.yaml
cat <<EOF > kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - github.com/ansible/awx-operator/config/default?ref=$AWX_OPERATOR_VERSION
images:
  - name: quay.io/ansible/awx-operator
    newTag: $AWX_OPERATOR_VERSION
namespace: awx
EOF

# Apply kustomization
kubectl apply -k .

# Create AWX instance configuration
cat <<EOF > bawzky.yml
---
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: bawzky
spec:
  service_type: clusterip
  ingress_type: Route
EOF

# Add bawzky.yml to kustomization resources
sed -i '/resources:/a\  - bawzky.yml
::contentReference[oaicite:0]{index=0}
 
