output "db_endpoint" {
  value = one(aws_db_instance.this[*].endpoint)
}

output "db_address" {
  value = one(aws_db_instance.this[*].address)
}

output "db_port" {
  value = one(aws_db_instance.this[*].port)
}

output "db_name" {
  value = var.db_name
}

output "parametros_ssm" {
  value = "/oficina/db"
}
