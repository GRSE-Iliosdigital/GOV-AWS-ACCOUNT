# Create a security group for Web_DB_server
resource "aws_security_group" "Web_DB_server_sg" {
  vpc_id      = aws_vpc.Goa_vpc.id
  name        = "Web_DB_server_sg"
  description = "Allow SSH and HTTP traffic for Web_DB_server"

  # Allow SSH from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress (Allow all traffic out)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web_DB_server_sg"
  }
}

# Define the EC2 instance Web_DB_server
resource "aws_instance" "Web_DB_server" {
  ami                    = var.ami           # Replace with the desired AMI (Amazon Linux 2, Ubuntu, etc.)
  instance_type         = "m6i.2xlarge"     # EC2 instance type
  key_name              = var.key_name       # SSH key pair to access the instance
  subnet_id             = aws_subnet.public_subnet.id  # Use the existing public subnet
  vpc_security_group_ids = [aws_security_group.Web_DB_server_sg.id]  # Use vpc_security_group_ids

  # Add a 500GB EBS volume with gp3 type
  ebs_block_device {
    device_name          = "/dev/sdh"  # Device name (can vary depending on the OS)
    volume_size          = 500         # Size in GB
    volume_type          = "gp3"       # General Purpose SSD (gp3)
    delete_on_termination = true       # Delete volume when instance is terminated
  }

  # Add a tag for easy identification
  tags = {
    Name = "Web_DB_server"
  }
}

# Create an Elastic IP
resource "aws_eip" "Web_DB_server_eip" {
  instance = aws_instance.Web_DB_server.id  # Associate EIP with the EC2 instance

  tags = {
    Name = "Web_DB_server_eip"
  }
}

# Output the public IP of the Web_DB_server instance
output "Web_DB_server_public_ip" {
  value = aws_instance.Web_DB_server.public_ip
}

# Output the public IP of the Web_DB_server instance
output "Web_DB_server_eip_public_ip" {
  value = aws_eip.Web_DB_server_eip.public_ip  # Output the EIP instead of the instance's public IP
}