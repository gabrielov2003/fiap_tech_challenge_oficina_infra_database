variable "region" {
  description = "Região AWS"
  default     = "us-east-1"
}

variable "db_identifier" {
  description = "Identificador da instância RDS"
  default     = "oficina-db"
}

variable "db_name" {
  description = "Nome do banco de dados"
  default     = "oficina"
}

variable "db_username" {
  description = "Usuário administrador do banco"
  default     = "oficina_admin"
}

variable "db_password" {
  description = "Senha do usuário administrador do banco"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "Classe da instância RDS"
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Armazenamento em GB"
  default     = 20
}

variable "publicly_accessible" {
  description = "Expõe a instância publicamente, use apenas em desenvolvimento"
  default     = false
}

variable "allowed_cidr_blocks" {
  description = "Blocos CIDR autorizados a acessar o banco na porta 5432"
  type        = list(string)
  default     = []
}
