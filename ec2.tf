resource "aws_instance" "sp-ec2" {
  depends_on = [
    aws_security_group.sg-ec2,
    aws_security_group.sg-alb
  ]

  ami                         = "ami-0ba39aef11896824a"
  instance_type               = "m5.2xlarge"
  subnet_id                   = aws_subnet.sp-sub-pub.id
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

# Atualizar pacotes
yum update -y

# Instalar Docker e Git
yum install -y git docker
usermod -a -G docker ec2-user
usermod -a -G docker ssm-user

# Ativar Docker
systemctl enable docker
systemctl start docker

# Instalar Docker Compose v2
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Adicionar swap
dd if=/dev/zero of=/swapfile bs=128M count=32
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile swap swap defaults 0 0" | tee -a /etc/fstab

# Instalar Node.js e npm
curl -fsSL https://rpm.nodesource.com/setup_21.x | bash -
yum install -y nodejs

# Instalar Python 3.11
amazon-linux-extras enable python3.11
yum install -y python3.11
ln -sf /usr/bin/python3.11 /usr/bin/python3

# Instalar uv
curl -LsSf https://astral.sh/uv/install.sh | sh

EOF
}
