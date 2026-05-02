variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "tp-ec2-hotel"
}

variable "instance_type" {
  description = "Type instance EC2"
  type        = string
  default     = "t3.micro"
}

variable "my_ip" {
  description = "Votre IP publique pour SSH"
  type        = string
  default     = ""
}