resource "aws_instance" "web_server-1" {
  ami           = "ami-0685bcc683dadb6b9" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.Private-1.id
  #key_name      = "vijay-key-pair"
  vpc_security_group_ids = [aws_security_group.Private_sg.id]
  user_data = file("user_data.sh")
  #associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.k8s_instance_profile.name

  tags = {
    Name = "WebServer-1"
  }
}
resource "aws_instance" "jenkins_server-1" {
  ami           = "ami-0685bcc683dadb6b9" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.Public-1.id
  #key_name      = "vijay-key-pair"
  vpc_security_group_ids = [aws_security_group.Jenkins_sg.id]
  user_data = file("userJenkins_data.sh")
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.jenkins_instance_profile.name

  tags = {
    Name = "JenkinsServer-1"
  }
}
resource "aws_instance" "web_server-2" {
  ami           = "ami-0685bcc683dadb6b9" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.Private-2.id
  #key_name      = "vijay-key-pair"
  vpc_security_group_ids = [aws_security_group.Private_sg.id]
  user_data = file("user_data.sh")
  #associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.k8s_instance_profile.name

  tags = {
    Name = "WebServer-2"
  }
}

resource "aws_lb_target_group" "Project_tg" {
  name     = "Project-tg"
  port     = 30005
  protocol = "HTTP"
  vpc_id   = aws_vpc.Projectvpc.id
  health_check {
    
  healthy_threshold   = 2
  unhealthy_threshold = 2
  timeout             = 3
  interval            = 30
  path                = "/health"
  port                = "30005"
  protocol            = "HTTP"
  matcher             = "200"

  }
  
}

resource "aws_lb_target_group_attachment" "Project_tg_attachment" {
  for_each         = {
    web_server_1 = aws_instance.web_server-1.id
    web_server_2 = aws_instance.web_server-2.id
  }

  target_group_arn = aws_lb_target_group.Project_tg.arn
  target_id        = each.value
  port             = 30005
}

resource "aws_lb" "Project_alb" {
  name               = "Project-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALB_sg.id]
  subnets            = [aws_subnet.Public-1.id, aws_subnet.Public-2.id]

  tags = {
    Name = "Project-alb"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.Project_alb.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Project_tg.arn
  }
}

# IAM Role for Private Web Servers to register with AWS Systems Manager
resource "aws_iam_role" "k8s_ssm_role" {
  name = "k8s-ssm-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core_attach" {
  role       = aws_iam_role.k8s_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "k8s_instance_profile" {
  name = "k8s-instance-profile"
  role = aws_iam_role.k8s_ssm_role.name
}

# IAM Role for Jenkins Server to allow sending remote shell deployment scripts
resource "aws_iam_role" "jenkins_role" {
  name = "jenkins-ssm-operator-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "jenkins_ssm_policy" {
  name        = "JenkinsSSMSendPolicy"
  description = "Allows Jenkins to execute pipeline deployment steps via SSM"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:SendCommand",
          "ssm:GetCommandInvocation"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_ssm_attach" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = aws_iam_policy.jenkins_ssm_policy.arn
}

resource "aws_iam_instance_profile" "jenkins_instance_profile" {
  name = "jenkins-instance-profile"
  role = aws_iam_role.jenkins_role.name
}

