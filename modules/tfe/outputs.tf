##################################
# DNS
##################################
output "tfe_url" {
  value = "https://${var.tfe_hostname}"
}

output "tfe_admin_console_url" {
  value = "https://${var.tfe_hostname}:8800"
}

output "tfe_alb_dns_name" {
  value = aws_lb.tfe_alb.dns_name
}
##################################
# S3
##################################
output "tfe_s3_app_bucket_name" {
  value = aws_s3_bucket.tfe_app.id
}

output "private_key" {
  value = "${tls_private_key.example.private_key_pem}"
}

output "tfe_vpc_id" {
  value = module.tfe-vpc.vpc_id
}

output "tfe_vpc_cidr_block" {
  value = module.tfe-vpc.public_subnets_cidr_blocks
}

output "tfe_vpc_public_route_table_ids" {
  value = module.tfe-vpc.public_route_table_ids
}

output "admin_vpc_id" {
  value = module.admin-vpc.vpc_id
}

output "admin_vpc_cidr_block" {
  value = module.admin-vpc.public_subnets_cidr_blocks
}

output "admin_vpc_public_route_table_ids" {
  value = module.admin-vpc.public_route_table_ids
}

# output "app_vpc_id" {
#   value = module.app-vpc.vpc_id
# }

# output "app_vpc_cidr_block" {
#   value = module.app-vpc.public_subnets_cidr_blocks
# }

# output "app_vpc_public_route_table_ids" {
#   value = module.app-vpc.public_route_table_ids
# }

# output "tfe_initial_admin_pw" {
#   value = random_password.tfe_initial_admin_pw[0].result
# }