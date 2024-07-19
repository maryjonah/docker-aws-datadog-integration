terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
    region = "us-east-2"
}

variable "flask_port" {
    type        = number
    default     = 5000
}

variable "http_port" {
    type        = number
    default     = 80
}

variable "ssh_port" {
    type        = number
    default     = 22
}

variable "outbound_anywhere" {
    type = number
    default = 0
}

# Security Group
resource "aws_security_group" "flask-terraform-sg" {
    name = "terraform-docker-datadog"

    ingress {
        description = "Flask"
        from_port   = var.flask_port
        to_port     = var.flask_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Webserver"
        from_port   = var.http_port
        to_port     = var.http_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "SSH"
        from_port   = var.ssh_port
        to_port     = var.ssh_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "Outbound"
        from_port   = var.outbound_anywhere
        to_port     = var.outbound_anywhere
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
    value       = aws_instance.flask.public_ip
    description = "Public IP of EC2 instance"
}

resource "aws_instance" "flask" {
    ami = "ami-0862be96e41dcbf74"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.flask-terraform-sg.id]

    user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install python3-venv -y
    sudo apt install docker.io
    sudo systemctl start docker
    sudo usermod -a -G docker ec2-user
    docker run -d --name sca-docker-datadog jonahmary17/mary-flask:latest
    docker run -d --name dd-agent \
    -e DD_API_KEY=${var.datadog_api_key} \
    -e DD_SITE="datadoghq.eu" \
    -e DD_APM_ENABLED=true \
    -e DD_APM_NON_LOCAL_TRAFFIC=true \
    -e DD_APM_RECEIVER_SOCKET=/opt/datadog/apm/inject/run/apm.socket \
    -e DD_DOGSTATSD_SOCKET=/opt/datadog/apm/inject/run/dsd.socket \
    -v /opt/datadog/apm:/opt/datadog/apm \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v /proc/:/host/proc/:ro \
    -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
    -v /var/lib/docker/containers:/var/lib/docker/containers:ro \
    gcr.io/datadoghq/agent:7
    EOF

    user_data_replace_on_change = true

    tags = {
        Name = "Docker-DataDog-Integration"
    }
}

variable "datadog_api_key" {
  description = "Datadog API Key"
  type        = string
}