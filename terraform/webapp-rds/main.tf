locals {
  db_name = "${var.task_name}db"
}

data "template_file" "task_definition" {
  template = file("templates/task-definition.json")
  vars = {
    container_memory = var.container_memory
    container_cpu    = var.container_cpu
    container_name   = var.container_name
    cluster_name     = var.cluster_name
    task_name        = var.task_name
    region           = var.region
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "logs" {
  statement {
    actions = [
      "logs:AssumeRole",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "logs" {
  name_prefix = substr(var.task_name, 0, 6)
  description = "ecs logs permission"
  policy      = data.aws_iam_policy_document.logs.json
}

resource "aws_iam_role_policy_attachment" "task_exec_role_policy" {
  role       = aws_iam_role.task_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.task_exec_role.name
  policy_arn = aws_iam_policy.logs.arn
}


resource "aws_iam_role" "task_exec_role" {
  name_prefix        = substr("task-${var.task_name}", 0, 6)
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

# main
resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name
}

resource "aws_ecs_task_definition" "task" {
  family = var.task_name

  container_definitions    = data.template_file.task_definition.rendered
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.container_memory
  cpu                      = var.container_cpu
  execution_role_arn       = aws_iam_role.task_exec_role.arn
}

resource "aws_security_group" "svc_sg" {
  name_prefix = "lb-svc"
  description = "inbound from load balancer to ecs service"

  vpc_id = module.network.vpc_id

  ingress {
    description     = "inbound from load balancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    self            = true
  }
  ingress {
    description     = "inbound https from load balancer"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    self            = true
  }
  egress {
    description     = "outbound traffic to the lb"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    self            = true
  }
  tags = merge({ Name = "lb-svc" }, var.tags)
}

resource "aws_ecs_service" "svc" {
  name            = var.task_name
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_count

  load_balancer {
    container_name   = var.container_name
    container_port   = 5555
    target_group_arn = aws_lb_target_group.default.arn
  }

  network_configuration {
    subnets          = tolist(module.network.public_subnet_ids)
    security_groups  = [aws_security_group.alb.id]
    assign_public_ip = true
  }
  depends_on = [aws_lb.alb]
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/${var.stage}/${var.task_name}/DB_PASSWORD"
  description = "The db password for ${var.task_name} ${local.db_name} db"
  type        = "SecureString"
  value       = var.db_password
  tags        = var.tags
}

resource "aws_security_group" "db" {
  name_prefix = substr(local.db_name, 0, 6)
  description = "Ingress and egress for ${local.db_name} RDS"
  vpc_id      = module.network.vpc_id
  tags        = merge({ Name = local.db_name }, var.tags)

  ingress {
    description = "db ingress from private subnets"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = tolist(module.network.private_subnet_cidrs)
  }
  egress {
    description = "db egress to private subnets"
    self        = true
    from_port   = 80
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = tolist(module.network.private_subnet_cidrs)
  }
}

module "db" {
  source     = "terraform-aws-modules/rds/aws"
  version    = "~> 2.0"
  identifier = "${local.db_name}-${var.stage}"

  engine            = "postgres"
  engine_version    = "11.8"
  instance_class    = var.db_instance_class
  allocated_storage = 20

  name     = local.db_name
  username = var.db_username
  password = var.db_password
  port     = "5432"

  vpc_security_group_ids = [aws_security_group.db.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # disable backups to create DB faster
  backup_retention_period = 0

  tags = var.tags

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # DB subnet group
  subnet_ids = tolist(module.network.private_subnet_ids)

  # DB parameter group
  family = "postgres11"

  # DB option group
  major_engine_version = "11"

  # Database Deletion Protection
  deletion_protection = false
}
