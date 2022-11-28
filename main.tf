locals {
  # nginx runs on port 80 by default
  port = 80

  /* Construct the task definition JSON (using a template).
   */
  container_definitions_json = jsonencode([
    jsondecode(templatefile("nginx.json.template", {
      # NB: the name of the container must match the target group config
      name = var.name
      port = local.port
      tag  = "latest"
    })),
  ])
}

/* Create an ECS cluster for the service.
 *
 * ECS clusters can be reused between services, but there's little reason to in practice.
 */
resource "aws_ecs_cluster" "service" {
  name = var.name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

/* Create an ECS task definition for the service.
 */
module "task_definition" {
  source  = "app.terraform.io/polycosm/ecs-task-definition/aws"
  version = "0.1.0"

  container_definitions_json = local.container_definitions_json
  cpu                        = var.cpu
  memory                     = var.memory
  name                       = var.name
}

/* Create an ECS task definition for the service.
 */
module "service" {
  source  = "app.terraform.io/polycosm/ecs-service/aws"
  version = "0.1.0"

  cluster = aws_ecs_cluster.service
  cpu     = var.cpu
  # NB: nginx is safe to start without any external dependencies
  initial_desired_count = 1
  load_balancer         = var.load_balancer
  hostname              = var.hostname
  memory                = var.memory
  name                  = var.name
  network               = var.network
  port                  = local.port
  task_definition       = module.task_definition
  zone                  = var.zone
}
