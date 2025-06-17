variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair to use"
  type        = string
  default     = "demo-key"
}

variable "public_key_path" {
  description = "Path to public key file to create key pair"
  type        = string
  default     = ""
}

variable "repo_url" {
  description = "Git repository URL containing the demo"
  type        = string
  default     = "https://github.com/example/service_mesh_demo.git"
}
