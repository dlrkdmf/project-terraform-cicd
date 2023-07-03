# 대상그룹 생성
resource "aws_lb_target_group" "myALB_TG" {
    name = "myALB-TG"
    port = 5000
    protocol = "HTTP"
    target_type = "ip"
    vpc_id = aws_vpc.my_VPC.id

    health_check {
        path = "/"
        protocol = "HTTP"
        matcher = "200"
        interval = 15
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
}

# alb 보안그룹 생성
resource "aws_security_group" "myALB_SG" {
    name = "myALB-SG"
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

    tags = {
        Name = "myALB_SG"
    }
}

# alb 생성
resource "aws_lb" "myALB" {
  name               = "myALB"
# internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.myALB_SG.id]
  subnets            = [aws_subnet.my_public_sn1.id, aws_subnet.my_public_sn2.id]

  tags = {
    Name = "myALB"
 }
}

# 대상 그룹과 로드 밸런서 연결
resource "aws_lb_listener" "myALB_listener" {
    load_balancer_arn = aws_lb.myALB.arn
    port = "5000"
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.myALB_TG.arn
    }
}
