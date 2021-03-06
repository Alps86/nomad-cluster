#!/usr/bin/env bash
set -e

echo "Grabbing IPs..."
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)

function installDependencies() {
  echo "Installing dependencies..."
  apt-get -qq update &>/dev/null
  apt-get -yqq install unzip &>/dev/null
}

function installDocker() {
  echo "Installing Docker..."
  apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
  apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
  apt-get update
  apt-get install -y docker-engine golang

  export GOPATH=/root/go
  export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

  go get -u -v github.com/awslabs/amazon-ecr-credential-helper/ecr-login/cli/docker-credential-ecr-login
  cp /root/go/bin/docker-credential-ecr-login /usr/local/bin/
}

function installConsul() {
  echo "Fetching Consul..."
  cd /tmp
  curl -sLo consul.zip https://releases.hashicorp.com/consul/$1/consul_$1_linux_amd64.zip
  
  echo "Installing Consul..."
  unzip consul.zip >/dev/null
  chmod +x consul
  mv consul /usr/local/bin/consul
  
  # Setup Consul
  mkdir -p /mnt/consul
  mkdir -p /etc/consul.d

  tee /home/ubuntu/docker_config.json > /dev/null <<"EOF"
{
  "credHelpers": {
    "${repository_name}.amazonaws.com": "ecr-login"
  }
}

EOF

  tee /etc/consul.d/config.json > /dev/null <<EOF
  ${consul_config}
EOF
  
  tee /etc/systemd/system/consul.service > /dev/null <<"EOF"
  [Unit]
  Description = "Consul"
  
  [Service]
  # Stop consul will not mark node as failed but left
  KillSignal=INT
  ExecStart=/usr/local/bin/consul agent -config-dir="/etc/consul.d"
  Restart=always
  ExecStopPost=sleep 5
EOF
}

function installNomad() {
  echo "Fetching Nomad..."
  cd /tmp
  curl -sLo nomad.zip https://releases.hashicorp.com/nomad/${nomad_version}/nomad_${nomad_version}_linux_amd64.zip
  
  echo "Installing Nomad..."
  unzip nomad.zip >/dev/null
  chmod +x nomad
  mv nomad /usr/local/bin/nomad
  
  # Setup Nomad
  mkdir -p /mnt/nomad
  mkdir -p /etc/nomad.d
  tee /etc/nomad.d/config.hcl > /dev/null <<EOF
  ${nomad_config}
EOF

  tee /etc/systemd/system/nomad.service > /dev/null <<"EOF"
  [Unit]
  Description = "Nomad"
  
  [Service]
  # Stop consul will not mark node as failed but left
  KillSignal=INT
  ExecStart=/usr/local/bin/nomad agent -config="/etc/nomad.d"
  Restart=always
  ExecStopPost=sleep 5
EOF
}

function installHashiUI() {
  echo "Fetching hashi-ui..."
  cd /tmp
  curl -sLo hashi-ui \
    https://github.com/jippi/hashi-ui/releases/download/v${hashiui_version}/hashi-ui-linux-amd64
  chmod +x hashi-ui
  mv hashi-ui /usr/local/bin/hashi-ui
  
  echo "Installing hashi-ui..."
  tee /etc/systemd/system/hashi-ui.service > /dev/null <<EOF
  [Unit]
  description="Hashi UI"
  
  [Service]
  KillSignal=INT
  ExecStart=/usr/local/bin/hashi-ui
  Restart=always
  RestartSec=5
  Environment=CONSUL_ENABLE=true
  Environment=NOMAD_ENABLE=true
  ExecStopPost=sleep 10
EOF
}


# Install software
installDependencies

if [[ ${consul_enabled} == 1 ]]; then
  installConsul ${consul_version}
fi

if [[ ${nomad_enabled} == 1 ]]; then
  installNomad ${nomad_version}
fi


if [[ ${nomad_enabled} == 1 && ${nomad_type} == "client" ]]; then
  installDocker
fi

if [[ ${hashiui_enabled} == 1 ]]; then
  installHashiUI ${hashiui_version}
fi


# Start services
systemctl daemon-reload
  
if [[ ${consul_enabled} == 1 ]]; then
  systemctl enable consul.service
  systemctl start consul.service
fi

if [[ ${nomad_enabled} == 1 ]]; then
  systemctl enable nomad.service
  systemctl start nomad.service
fi

if [[ ${hashiui_enabled} == 1 ]]; then
  systemctl enable hashi-ui.service
  systemctl start hashi-ui.service
fi
