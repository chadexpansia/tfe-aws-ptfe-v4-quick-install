# output "eu_vpc" {
#     value = module.eu-tfe.tfe_vpc_id
# }

output "west_vpc" {
    value = module.west-tfe.tfe_vpc_id
}

# output "eu_private_key" {
#   value = module.eu-tfe.private_key
# }

output "west_private_key" {
  value = module.west-tfe.private_key
}

# output "TFE_password" {
#     value = module.west-tfe.tfe_initial_admin_pw
# }