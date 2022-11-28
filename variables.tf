variable "cpu" {
  default = 256
  type    = number
}

variable "hostname" {
  type = string
}

variable "load_balancer" {
  description = "The load balancer configuration to use."
  type = object({
    arn               = string
    dns_name          = string
    https_listener_id = string
    zone_id           = string
  })
}

variable "memory" {
  default = 512
  type    = number
}

variable "name" {
  default = "nginx"
  type    = string
}

variable "network" {
  description = "The network to use"
  type = object({
    private_subnets = list(string)
    vpc_id          = string
  })
}

variable "zone" {
  description = "The Route53 zone in which to create the service record"
  type = object({
    id = string
  })
}
