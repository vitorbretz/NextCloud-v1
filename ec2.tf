resource "aws_instance" "sp-ec2" {
  depends_on = [
    aws_security_group.sg-ec2,
    aws_security_group.sg-alb
  ]

  ami                         = "ami-0ba39aef11896824a"
  instance_type               = "m5.2xlarge"
  subnet_id                   = aws_subnet.sp-sub-pub-1a.id
  associate_public_ip_address = true
  key_name                    = "acessa-infra-antiga"

  # Usa o SG criado no Terraform
  vpc_security_group_ids = [aws_security_group.sg-ec2.id]

  root_block_device {
    volume_size = 500
    volume_type = "gp2"
  }

  tags = {
    Name = "${var.project_name}-ec2"
  }

  user_data = <<-EOF
#!/bin/bash
set -euxo pipefail
# ------------------------------------------------------------
# SCRIPT SEGURO E OTIMIZADO PARA AMAZON LINUX 2023
# Objetivo: preparar EC2 para uso com Docker, AWS CLI, Node.js e Python
# ------------------------------------------------------------

# --- Atualização básica do sistema ---
# Evita travar o yum/dnf se rodar durante o boot
sleep 10
sudo dnf clean all
sudo dnf update -y

# --- Instalar pacotes essenciais ---
sudo dnf install -y git docker jq unzip curl tar

# --- Instalar AWS CLI v2 ---
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -q /tmp/awscliv2.zip -d /tmp
sudo /tmp/aws/install --update
rm -rf /tmp/aws /tmp/awscliv2.zip

# --- Configurar Docker ---
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo usermod -aG docker ec2-user
sudo usermod -aG docker ssm-user

# --- Instalar Docker Compose v2 ---
sudo mkdir -p /usr/local/lib/docker/cli-plugins
sudo curl -fsSL "https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-linux-x86_64" \
    -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# --- Instalar Node.js 21 ---
curl -fsSL https://rpm.nodesource.com/setup_21.x | sudo bash -
sudo dnf install -y nodejs

# --- Instalar Python 3.10 e configurar ---
sudo dnf install -y python3.10
sudo ln -sf /usr/bin/python3.10 /usr/bin/python3

# --- Instalar UV (gerenciador de pacotes para Python, compatível com MCP da AWS) ---
sudo -u ec2-user bash -c '
  export PATH="$HOME/.local/bin:$PATH"
  curl -LsSf https://astral.sh/uv/install.sh | sh
  echo "export PATH=\$HOME/.local/bin:\$PATH" >> /home/ec2-user/.bashrc
'

# --- Corrigir DNS persistente (caso perca resolução) ---
# Essa configuração impede perda de /etc/resolv.conf após updates
sudo bash -c 'cat > /etc/systemd/resolved.conf <<EOF
[Resolve]
DNS=8.8.8.8 1.1.1.1
FallbackDNS=9.9.9.9
DNSStubListener=no
EOF'
sudo systemctl enable systemd-resolved
sudo systemctl restart systemd-resolved
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

# --- Log final ---
echo "Setup concluído com sucesso em $(date)" | sudo tee /var/log/setup-complete.log

# ------------------------------------------------------------
# COMANDOS ADICIONAIS: CLONAR REPOSITÓRIO NEXTCLOUD E SUBIR CONTAINERS
# ------------------------------------------------------------

# Entrar no diretório do ec2-user
cd /home/ec2-user

# Clonar o repositório
git clone https://github.com/henrylle/proj-nextcloud.git /home/ec2-user/proj-nextcloud
cd /home/ec2-user/proj-nextcloud

# Subir containers com Docker Compose
sudo docker compose up -d



EOF
}
