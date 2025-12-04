#!/bin/bash
set -e

# Install Vault
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update && apt-get install -y vault=${vault_version}

# Configure Vault
cat > /etc/vault.d/vault.hcl <<EOF
ui = true

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_disable   = false
  tls_cert_file = "/etc/vault.d/tls/vault.crt"
  tls_key_file  = "/etc/vault.d/tls/vault.key"
}

storage "raft" {
  path    = "/opt/vault/data"
  node_id = "$(hostname)"

  retry_join {
    auto_join         = "provider=aws tag_key=Name tag_value=${vault_cluster_tag} region=${aws_region}"
    auto_join_scheme  = "https"
  }
}

seal "awskms" {
  region     = "${aws_region}"
  kms_key_id = "${kms_key_id}"
}

api_addr     = "https://$(hostname):8200"
cluster_addr = "https://$(hostname):8201"

telemetry {
  disable_hostname = true
}
EOF

# Create data directory
mkdir -p /opt/vault/data
chown -R vault:vault /opt/vault

# Start Vault
systemctl enable vault
systemctl start vault
