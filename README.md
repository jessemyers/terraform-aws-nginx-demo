# terraform-aws-nginx-demo

Terraform module to demonstrate an nginx ECS service.

This module both uses and depends on several Terraform modules that are available in this
GitHub organization:

 - https://github.com/polycosm/terraform-aws-network
 - https://github.com/polycosm/terraform-aws-wildcard-certificate
 - https://github.com/polycosm/terraform-aws-alb
 - https://github.com/polycosm/terraform-aws-ecs-task-definition
 - https://github.com/polycosm/terraform-aws-ecs-service

An example usage is something like:


```tf
locals {
   cidr_block       = "10.42.0.0/16"
   root_domain_name = "polycosm.io"
}

data "aws_route53_zone" "root" {
  name = local.root_domain_name
}

module "network" {
  source  = "app.terraform.io/polycosm/network/aws"
  version = "0.1.0"

  cidr_block = local.cidr_block
  name       = "demo"
}

module "wildcard_certificate" {
  source  = "app.terraform.io/polycosm/wildcard-certificate/aws"
  version = "0.1.0"

  root_domain_name = "ecs.${local.root_domain_name}"
  zone             = data.aws_route53_zone.root
}

module "load_balancer" {
  source  = "app.terraform.io/polycosm/alb/aws"
  version = "0.1.0"

  internal             = false
  name                 = "public"
  wildcard_certificate = module.wildcard_certificate
  network              = module.network
}

module "nginx" {
  source  = "app.terraform.io/polycosm/nginx-demo/aws"
  version = "0.1.0"

  hostname      = "nginx.ecs.${locoal.root_domain_name}"
  load_balancer = module.load_balancer
  network       = module.network
  zone          = data.aws_route53_zone.root
}
```
