# Provider definition
provider "aws" {
  region = "ap-south-1"  # Set region to ap-south-1 (Mumbai)
}

# Create a VPC
resource "aws_vpc" "Goa_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Goa_vpc"
  }
}

# Create a public subnet within the VPC
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.Goa_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true  # Automatically assign public IPs

  tags = {
    Name = "public_subnet"
  }
}

# Create a private subnet within the VPC
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.Goa_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
  
  tags = {
    Name = "private_subnet"
  }
}

# Create an Internet Gateway to enable access to the Internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.Goa_vpc.id

  tags = {
    Name = "Goa_igw"
  }
}

# Create a Route Table for the public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.Goa_vpc.id

  route {
    cidr_block = "0.0.0.0/0"  # Route all outbound traffic to the Internet
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

# Associate the public subnet with the route table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Define a security group for api_server_1 (First EC2 instance)
resource "aws_security_group" "api_server_1_sg" {
  vpc_id      = aws_vpc.Goa_vpc.id
  name        = "api_server_1_sg"
  description = "Allow SSH and HTTP traffic"

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
    Name = "api_server_1_sg"
  }
}

# Define the EC2 instance api_server_1
resource "aws_instance" "api_server_1" {
  ami           = var.ami           # Replace with the desired AMI (Amazon Linux 2, Ubuntu, etc.)
  instance_type = "t3.xlarge"       # EC2 instance type
  key_name      = var.key_name      # SSH key pair to access the instance
  subnet_id     = aws_subnet.public_subnet.id  # Launch in the public subnet
  vpc_security_group_ids = [aws_security_group.api_server_1_sg.id]

  # Add an EBS volume of 100GB with gp3 type
  ebs_block_device {
    device_name = "/dev/sdh"  # Device name (can vary depending on the OS)
    volume_size = 100         # Size in GB
    volume_type = "gp3"       # General Purpose SSD (gp3)
    delete_on_termination = true  # Delete volume when instance is terminated
  }

  # Add a tag for easy identification
  tags = {
    Name = "api_server_1"
  }
}

# Create an Elastic IP
resource "aws_eip" "api_server_1_eip" {
  instance = aws_instance.api_server_1.id  # Associate EIP with the EC2 instance

  tags = {
    Name = "api_server_1_eip"
  }
}

# Define a security group for api_server_2 (Second EC2 instance)
resource "aws_security_group" "api_server_2_sg" {
  vpc_id      = aws_vpc.Goa_vpc.id
  name        = "api_server_2_sg"
  description = "Allow SSH and HTTP traffic"

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
    Name = "api_server_2_sg"
  }
}

# Define the EC2 instance api_server_2
resource "aws_instance" "api_server_2" {
  ami           = var.ami           # Replace with the desired AMI (Amazon Linux 2, Ubuntu, etc.)
  instance_type = "t3.xlarge"       # EC2 instance type
  key_name      = var.key_name      # SSH key pair to access the instance
  subnet_id     = aws_subnet.public_subnet.id  # Launch in the public subnet
  vpc_security_group_ids = [aws_security_group.api_server_2_sg.id]

  # Add an EBS volume of 100GB with gp3 type
  ebs_block_device {
    device_name = "/dev/sdh"  # Device name (can vary depending on the OS)
    volume_size = 100         # Size in GB
    volume_type = "gp3"       # General Purpose SSD (gp3)
    delete_on_termination = true  # Delete volume when instance is terminated
  }

  # Add a tag for easy identification
  tags = {
    Name = "api_server_2"
  }
}

# Create an Elastic IP
resource "aws_eip" "api_server_2_eip" {
  instance = aws_instance.api_server_2.id  # Associate EIP with the EC2 instance

  tags = {
    Name = "api_server_2_eip"
  }
}

# Output the public IPs for both instances
output "instance_public_ip_1" {
  value = aws_instance.api_server_1.public_ip
}

output "instance_public_ip_2" {
  value = aws_instance.api_server_2.public_ip
}

# Output the public IP of the Web_DB_server instance
output "instance_public_eip_1" {
  value = aws_eip.api_server_1_eip.public_ip  # Output the EIP instead of the instance's public IP
}

# Output the public IP of the Web_DB_server instance
output "instance_public_eip_2" {
  value = aws_eip.api_server_2_eip.public_ip  # Output the EIP instead of the instance's public IP
}