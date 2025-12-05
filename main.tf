provider "aws" {
  region = "ap-southeast-1"
}

# 1️⃣ New Key Pair
resource "aws_key_pair" "jarvis_key_v2" {
  key_name   = "jarvis-key-v2"
  public_key = file("~/.ssh/jarvis-key-v2.pub")
}

# 2️⃣ New Security Group
resource "aws_security_group" "jarvis_sg_v2" {
  name = "jarvis-sg-v2"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3️⃣ New EC2 instance
resource "aws_instance" "jarvis_ec2_v2" {
  ami           = "ami-093a7f5fbae13ff67"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.jarvis_key_v2.key_name
  security_groups = [aws_security_group.jarvis_sg_v2.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y python3-pip git
              cd /home/ubuntu
              git clone https://github.com/payalpachangane/Deploy-Jarvis-Desktop-Voice-Assistant.git
              cd Deploy-Jarvis-Desktop-Voice-Assistant
              pip3 install -r requirements.txt

              sudo bash -c 'cat > /etc/systemd/system/jarvis.service << EOL
              [Unit]
              Description=Jarvis Desktop Voice Assistant
              After=network.target

              [Service]
              User=ubuntu
              WorkingDirectory=/home/ubuntu/Deploy-Jarvis-Desktop-Voice-Assistant
              ExecStart=/usr/bin/python3 /home/ubuntu/Deploy-Jarvis-Desktop-Voice-Assistant/jarvis.py
              Restart=always

              [Install]
              WantedBy=multi-user.target
              EOL'

              sudo systemctl daemon-reload
              sudo systemctl enable jarvis.service
              sudo systemctl start jarvis.service
              EOF

  tags = {
    Name = "Jarvis-EC2-V2"
  }
}
