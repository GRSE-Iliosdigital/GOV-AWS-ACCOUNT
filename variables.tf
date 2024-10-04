# You can provide these in a separate file or directly in your main.tf
variable "key_name" {
  default = "goa"  # Replace with your actual key pair name
}

variable "ami" {
  default = "ami-0dee22c13ea7a9a67"  # Example Amazon Linux 2 AMI (for us-east-1); replace with your desired AMI ID
}
