terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDcXU4MSp67vFdnTZlB8DV8pSbDqVmSR9IkHBt1r9MfA+Q429cTy3tmavpu3Eb0bgulskOPB38HWa2Z5HdQxgC/lELY8zdvJNyN67NfTUT7ihSMOty4ndIRMo6w6cdDWw34yVcoBR7ZUzKU6MwCZDwBJHPCfeUB4R6YqXwI+K4eY499YMRn4kQzDJpeCYWMSH6Pz0z0mHpYTFGUbOnC35QauRoCtDpFmesfTu6KRsez67cmmR/Sztnys4xnwEgi4D+VGCsgH+ezoZ2/nK+vgHKU58kKE04S0tqhNd0DUtyIqkI7Suns35Fa3GQsXjaliSdi3AOAQpERiWFKgFIc3JPD"
}

provider "aws" {
  profile = "default"
  region  = "us-west-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "main-route-table"
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow Public SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Public SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "block_egress" {
  name        = "block_egress"
  description = "Block all outbound"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "block_egress"
  }
}

resource "aws_instance" "app_server_1" {
  ami                         = "ami-0528712befcd5d885"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.allow_tls.id, aws_security_group.allow_elb.id, aws_security_group.allow_ssh.id, aws_security_group.block_egress.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.deployer.key_name

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "fruit-microservice"
  }
}

resource "aws_instance" "app_server_2" {
  ami                         = "ami-0528712befcd5d885"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.allow_tls.id, aws_security_group.allow_elb.id, aws_security_group.allow_ssh.id, aws_security_group.block_egress.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.deployer.key_name

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "fruit-microservice"
  }
}

resource "aws_security_group" "allow_elb" {
  name        = "allow_elb"
  description = "Allow HTTP inbound traffic for Load Balancers"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from Load Balancer"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  tags = {
    Name = "allow_elb"
  }
}

resource "aws_s3_bucket" "logs-bucket" {
  bucket = "bitescorp-logs-bucket"

  tags = {
    Name        = "logs-bucket"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_acl" "logs-bucket" {
  bucket = aws_s3_bucket.logs-bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "logs-bucket" {
  bucket = aws_s3_bucket.logs-bucket.id
  policy = data.aws_iam_policy_document.s3_bucket_lb_write.json
}

data "aws_elb_service_account" "elb-service-account" {}

data "aws_iam_policy_document" "s3_bucket_lb_write" {
  policy_id = "s3_bucket_lb_logs"

  statement {
    actions = [
      "s3:PutObject",
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.logs-bucket.arn}/*",
    ]

    principals {
      identifiers = ["${data.aws_elb_service_account.elb-service-account.arn}"]
      type        = "AWS"
    }
  }

  statement {
    actions = [
      "s3:PutObject"
    ]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.logs-bucket.arn}/*"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }


  statement {
    actions = [
      "s3:GetBucketAcl"
    ]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.logs-bucket.arn}"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "logs-bucket" {
  bucket = aws_s3_bucket.logs-bucket.id

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_elb" "fruit-elb" {
  name    = "fruit-elb"
  subnets = [aws_subnet.main.id]

  access_logs {
    bucket        = aws_s3_bucket.logs-bucket.bucket
    bucket_prefix = "fruit"
    interval      = 60
  }

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  #   listener {
  #     instance_port      = 8000
  #     instance_protocol  = "http"
  #     lb_port            = 443
  #     lb_protocol        = "https"
  #     ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
  #   }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                   = [aws_instance.app_server_1.id, aws_instance.app_server_2.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "fruit-elb"
  }
}

resource "aws_lb_cookie_stickiness_policy" "fruit-elb-sticky-policy" {
  name                     = "fruit-elb-sticky-policy"
  load_balancer            = aws_elb.fruit-elb.id
  lb_port                  = 80
  cookie_expiration_period = 600
}