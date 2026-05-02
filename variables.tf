variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "tp-ha-pritunl"
}

variable "vpc_cidr" {
  description = "CIDR block du VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs des subnets publics"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs des subnets privés"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t3.micro"
}

variable "db_password" {
  description = "Mot de passe de la base de données"
  type        = string
  default     = "PritunlDB2024!"
  sensitive   = true
}

variable "db_username" {
  description = "Nom d'utilisateur de la base de données"
  type        = string
  default     = "pritunladmin"
}