# ECSTaskExecution 역할 생성
resource "aws_iam_role" "ecs_task_execution_role" {
    name = "ecs-task-execution-role"

    assume_role_policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "",
                "Effect": "Allow",
                "Action": "sts:AssumeRole",
                "Principal": {
                    "Service": "ecs-tasks.amazonaws.com"
                }
            }
        ]
    }
    EOF
}

# ECStaskExecution 정책
data "aws_iam_policy" "ECS_TaskExecution" {
    name = "AmazonECSTaskExecutionRolePolicy"
}

# ECStaskExecution 정책 연결
resource "aws_iam_role_policy_attachment" "attach" {
    role = aws_iam_role.ecs_task_execution_role.name
    policy_arn = data.aws_iam_policy.ECS_TaskExecution.arn
}

# ECS TASK 정의
resource "aws_ecs_task_definition" "my-web" {
    family                   = "my-web"
    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"
    execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
    #task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
    cpu                      = 1024
    memory                   = 2048
    container_definitions    = <<-EOF
[
    {
        "name": "my-web",
        "image": "905944532563.dkr.ecr.ap-northeast-2.amazonaws.com/my-image-repo:latest",
        "portMappings": [
            {
                "name": "my-web-5000-tcp",
                "containerPort": 5000,
                "hostPort": 5000,
                "protocol": "tcp",
                "appProtocol": "http"
            }
        ],
        "essential": true
    }
]
EOF

    runtime_platform {
        operating_system_family = "LINUX"
        cpu_architecture        = "X86_64"
    }
}

# ECS 클러스터 생성
resource "aws_ecs_cluster" "my_cluster" {
    name = "my-ecs-cluster"
}

# ECS Task 보안그룹 생성
resource "aws_security_group" "ecs_tasks_SG" {
    name = "ecs_tasks_SG"
    description = "Allow 5000/tcp"
    vpc_id = aws_vpc.my_VPC.id

    ingress {
        description = "Allow 5000/tcp"
        from_port = 5000
        to_port = 5000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# ECS 서비스 생성
resource "aws_ecs_service" "my-web-svc" {
    depends_on      = [aws_lb_target_group.myALB_TG]
    name            = "my-web-svc"
    cluster         = aws_ecs_cluster.my_cluster.id
    task_definition = aws_ecs_task_definition.my-web.arn
    desired_count   = 2
    launch_type     = "FARGATE"

    load_balancer {
        target_group_arn  = aws_lb_target_group.myALB_TG.arn
        container_name    = "my-web"
        container_port    = 5000
    }

    network_configuration {
        security_groups = [aws_security_group.ecs_tasks_SG.id]
        subnets         = [aws_subnet.my_private_sn1.id, aws_subnet.my_private_sn2.id]
    }
}


