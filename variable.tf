variable "region" {
  description = "AWS region"
  default     = "us-west-1"
}

variable "instance_type" {
  description = "AWS instance type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "AWS key pair name"
  default     = "docker_mastery"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  default     = "my-swarm-tokens-bucket"
}

