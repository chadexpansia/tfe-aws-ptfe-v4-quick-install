provider "aws" {
  alias  = "eu-central-1"
  region = "eu-central-1"
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
}

provider "aws" {
  alias  = "us-west-1"
  region = "us-west-1"
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
}

# Get available azs for west
data "aws_availability_zones" "west-azs" {
  provider = aws.us-west-1
  state = "available"
}

# module "eu-tfe" {
#   source = "./modules/tfe"
#   providers = {
#     aws = aws.eu-central-1
#   }
# #static variables
#   friendly_name_prefix       = var.friendly_name_prefix
#   common_tags                = var.common_tags
#   tfe_license_file_path      = var.tfe_license_file_path
#   tfe_release_sequence       = var.tfe_release_sequence
#   tfe_initial_admin_username = var.tfe_initial_admin_username
#   tfe_initial_admin_email    = var.tfe_initial_admin_email
#   tfe_initial_admin_pw       = var.tfe_initial_admin_pw
#   tfe_initial_org_name       = var.tfe_initial_org_name
# #dynamic variables
#   tfe_hostname               = var.tfe_hostname
#   route53_hosted_zone_name   = var.route53_hosted_zone_name
#   kms_key_arn                = var.kms_key_arn
#   ingress_cidr_alb_allow     = ["0.0.0.0/0"] #var.ingress_cidr_alb_allow
#   ingress_cidr_ec2_allow     = ["0.0.0.0/0"] #var.ingress_cidr_ec2_allow
#   vpc_public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
#   vpc_azs = ["eu-central-1a", "eu-central-1b"]
# }

module "west-tfe" {
  source = "./modules/tfe"
  providers = {
    aws = aws.us-west-1
  }
#static variables
  friendly_name_prefix       = var.friendly_name_prefix
  common_tags                = var.common_tags
  tfe_license_file_path      = var.tfe_license_file_path
  tfe_release_sequence       = var.tfe_release_sequence
  tfe_initial_admin_username = var.tfe_initial_admin_username
  tfe_initial_admin_email    = var.tfe_initial_admin_email
  tfe_initial_admin_pw       = var.tfe_initial_admin_pw
  tfe_initial_org_name       = var.tfe_initial_org_name
#dynamic variables
  tfe_hostname               = var.tfe_hostname
  route53_hosted_zone_name   = var.route53_hosted_zone_name
  kms_key_arn                = var.kms_key_arn
  ingress_cidr_alb_allow     = ["0.0.0.0/0"] #var.ingress_cidr_alb_allow
  ingress_cidr_ec2_allow     = ["0.0.0.0/0"] #var.ingress_cidr_ec2_allow
  vpc_public_subnets         = ["10.0.101.0/24", "10.0.102.0/24"]
  admin_vpc_public_subnets   = ["10.1.101.0/24", "10.1.102.0/24"]
  vpc_azs = data.aws_availability_zones.west-azs.names#["us-west-1a", "us-west-1c"]
  instance_size              = "m5.xlarge"
}



# # Accepter's side of the connection.
# resource "aws_vpc_peering_connection_accepter" "peer" {
#   provider                  = aws.us-west-1
#   vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
#   auto_accept               = true
# }

# resource "aws_route" "eu-vpc" {
#   provider                  = aws.eu-central-1
# # Need to create a route for every combination of route_table_id on module.eu-vpc.public_route_table_ids with every cidr_block on module.west-vpc.public_cidr_blocks. Look into setproduct function. Using setproduct, element, and length, this can be done dynamically
#   count                     = 1
#   route_table_id            = module.eu-tfe.vpc_public_route_table_ids[0]
#   destination_cidr_block    = module.west-tfe.vpc_cidr_block[0]
#   vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
# }

# resource "aws_route" "west-vpc" {
#   provider                  = aws.us-west-1
# # Need to create a route for every combination of route_table_id on module.west-vpc.public_route_table_ids with every cidr_block on module.eu-vpc.public_cidr_blocks. Look into setproduct function. Using setproduct, element, and length, this can be done dynamically
#   count                     = 1
#   route_table_id            = module.west-tfe.vpc_public_route_table_ids[0]
#   destination_cidr_block    = module.eu-tfe.vpc_cidr_block[0]
#   vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
# }


