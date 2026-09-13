variable "region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "db_identifier" {
  description = "Identificador da instância RDS"
  type        = string
  default     = "oficina-db"
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
  default     = "oficina"
}

variable "db_username" {
  description = "Usuário administrador do banco"
  type        = string
  default     = "oficina_admin"
}

variable "engine_version" {
  description = "Versão principal do PostgreSQL"
  type        = string
  default     = "16"
}

variable "instance_class" {
  description = "Classe da instância RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Armazenamento inicial em GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Limite do autoscaling de armazenamento em GB"
  type        = number
  default     = 50
}

variable "multi_az" {
  description = "Cria uma réplica em outra zona de disponibilidade para alta disponibilidade"
  type        = bool
  default     = false
}

variable "allowed_cidr_blocks" {
  description = "Blocos CIDR extras autorizados na porta 5432, além da VPC do cluster"
  type        = list(string)
  default     = []
}
