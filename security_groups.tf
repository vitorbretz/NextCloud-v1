# Pega automaticamente o IP público da rede que está rodando o Terraform
data "http" "meu_ip" {
  url = "https://checkip.amazonaws.com/"
}

# Security Group da EC2
resource "aws_security_group" "sg-ec2" {
  name        = "security-ec2"
  description = "Acesso a EC2 apenas via ALB e SSH do meu IP"
  vpc_id      = aws_vpc.sp-vpc.id

  # Saída liberada para qualquer destino
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Acesso vindo apenas do ALB
  ingress {
  description     = "Acesso HTTP do ALB"
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  security_groups = [aws_security_group.sg-alb.id]
}


  # Acesso SSH apenas do seu IP público atual
  ingress {
    description = "Acesso SSH apenas da minha rede"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.meu_ip.response_body)}/32"]
  }

  tags = {
    Name = "security-ec2"
  }
}

# Security Group do ALB
resource "aws_security_group" "sg-alb" {
  name        = "security-alb"
  description = "Acesso publico ao ALB"
  vpc_id      = aws_vpc.sp-vpc.id

  # Saída liberada
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Entrada HTTP (80)
  ingress {
    description = "HTTP liberado para o mundo"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Entrada HTTPS (443)
  ingress {
    description = "HTTPS liberado para o mundo"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "security-alb"
  }
}


# Security Group Aurora

resource "aws_security_group" "sg-aurora" {
  name        = "security-aurora"
  description = "Acesso ao Aurora PostgreSQL apenas pela EC2"
  vpc_id      = aws_vpc.sp-vpc.id

  # Saída liberada
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Entrada PostgreSQL (5432) apenas da EC2
  ingress {
    description     = "Acesso PostgreSQL apenas da EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.sg-ec2.id]
  }

  tags = {
    Name = "security-aurora"
  }
}