provider "aws" {
  profile = "default"
  region  = "us-west-1" # TODO add to variables
}

locals {
  name   = "bites-fruit"
  region = "us-west-1"
  tags = {
    App         = "fruit"
    Environment = "production"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "terraform-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDcXU4MSp67vFdnTZlB8DV8pSbDqVmSR9IkHBt1r9MfA+Q429cTy3tmavpu3Eb0bgulskOPB38HWa2Z5HdQxgC/lELY8zdvJNyN67NfTUT7ihSMOty4ndIRMo6w6cdDWw34yVcoBR7ZUzKU6MwCZDwBJHPCfeUB4R6YqXwI+K4eY499YMRn4kQzDJpeCYWMSH6Pz0z0mHpYTFGUbOnC35QauRoCtDpFmesfTu6KRsez67cmmR/Sztnys4xnwEgi4D+VGCsgH+ezoZ2/nK+vgHKU58kKE04S0tqhNd0DUtyIqkI7Suns35Fa3GQsXjaliSdi3AOAQpERiWFKgFIc3JPD"
  tags       = local.tags
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = "10.0.0.0/16"

  azs              = ["${local.region}a", "${local.region}c"]
  public_subnets   = ["10.0.0.0/24", "10.0.2.0/24"]
  private_subnets  = ["10.0.3.0/24", "10.0.5.0/24"]
  database_subnets = ["10.0.7.0/24", "10.0.9.0/24"]

  create_database_subnet_group       = true
  create_database_subnet_route_table = true

  enable_nat_gateway = false

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = local.tags
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  tags = local.tags
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow Public SSH inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Public SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_security_group" "allow_postgres_egress" {
  name        = "allow_postgres_egress"
  description = "Allow Postgres outbound traffic"
  vpc_id      = module.vpc.vpc_id

  egress {
    description = "Postgres Access"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  tags = local.tags
}

resource "aws_security_group" "allow_internal_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow internal HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = module.vpc.public_subnets_cidr_blocks
  }

  tags = local.tags
}

resource "aws_security_group" "allow_elb_http" {
  name        = "allow_elb_http"
  description = "Allow ingress/egress HTTP traffic for load balancer"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTP to public subnets"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = module.vpc.public_subnets_cidr_blocks
  }

  tags = local.tags
}

module "fruit_instances_a" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = toset(["1"])

  name = "fruit-service-a-${each.key}"

  ami           = "ami-0528712befcd5d885"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  monitoring    = true
  vpc_security_group_ids = [
    module.vpc.default_security_group_id,
    aws_security_group.allow_internal_http.id,
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_postgres_egress.id
  ]
  subnet_id = module.vpc.public_subnets[0]

  tags = local.tags
}

module "fruit_instances_b" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = toset(["1"])

  name = "fruit-service-b-${each.key}"

  ami           = "ami-0528712befcd5d885"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  monitoring    = true
  vpc_security_group_ids = [
    module.vpc.default_security_group_id,
    aws_security_group.allow_internal_http.id,
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_postgres_egress.id
  ]
  subnet_id = module.vpc.public_subnets[1]

  tags = local.tags
}

module "fruit-db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "fruit-db"

  engine               = "postgres"
  engine_version       = "13.3"
  family               = "postgres13"
  major_engine_version = "13"
  instance_class       = "db.t4g.micro"
  allocated_storage    = 5

  db_name  = "fruit"
  username = "fruit_worker"
  port     = "5432"

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [module.vpc.default_security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  #   monitoring_interval = "30"
  #   monitoring_role_name = "MyRDSMonitoringRole"
  #   create_monitoring_role = true

  # DB subnet mapping
  subnet_ids           = module.vpc.database_subnets
  db_subnet_group_name = module.vpc.database_subnet_group_name

  deletion_protection = false # TODO change this when *actually* running prod

  parameters = []

  options = []

  tags = local.tags
}

resource "aws_s3_bucket" "logs-bucket" {
  bucket = "bitescorp-logs-bucket"

  tags = local.tags
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
  name            = "fruit-elb"
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.allow_elb_http.id]

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
    target              = "HTTP:80/fruits"
    interval            = 30
  }

  instances = concat(
    [for instance in module.fruit_instances_a : instance.id],
    [for instance in module.fruit_instances_b : instance.id]
  )
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = local.tags
}

resource "aws_lb_cookie_stickiness_policy" "fruit-elb-sticky-policy" {
  name                     = "fruit-elb-sticky-policy"
  load_balancer            = aws_elb.fruit-elb.id
  lb_port                  = 80
  cookie_expiration_period = 600
}

# resource "aws_prometheus_workspace" "prod" {
#   alias = "prometheus-prod"

#   tags = local.tags
# }