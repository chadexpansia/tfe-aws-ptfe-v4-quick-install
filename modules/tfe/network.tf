data "aws_availability_zones" "azs" {
  #provider = data.aws_region.current.name
  state = "available"
}

module "tfe-vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "tfe"
  cidr = "10.0.0.0/16"
  azs  = var.vpc_azs
  #data.aws_availability_zones.azs.names[0], data.aws_availability_zones.azs.names[1]], data.aws_availability_zones.azs.names[2]]

# Use cidrsubnet function with for_each to create the right number of subnets
  public_subnets  = var.vpc_public_subnets#["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

module "admin-vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "admin"
  cidr = "10.1.0.0/16"
  azs  = var.vpc_azs
  public_subnets  = var.admin_vpc_public_subnets
  #data.aws_availability_zones.azs.names[0], data.aws_availability_zones.azs.names[1]], data.aws_availability_zones.azs.names[2]]

# Use cidrsubnet function with for_each to create the right number of subnets
  #public_subnets  = var.vpc_public_subnets#["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

# module "app-vpc" {
#   source = "terraform-aws-modules/vpc/aws"
#   name = "app"
#   cidr = "10.2.0.0/16"
#   azs  = var.vpc_azs
#   #data.aws_availability_zones.azs.names[0], data.aws_availability_zones.azs.names[1]], data.aws_availability_zones.azs.names[2]]

# # Use cidrsubnet function with for_each to create the right number of subnets
#   #public_subnets  = var.vpc_public_subnets#["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
# }

###########################################################
#             Create Peering in Region                    #
###########################################################
#Create peering between admin and tfe
resource "aws_vpc_peering_connection" "admin_tfe" {
  vpc_id        = module.admin-vpc.vpc_id
  peer_vpc_id   = module.tfe-vpc.vpc_id
  auto_accept   = true
}

# #Create peering between admin and app
# resource "aws_vpc_peering_connection" "admin_app" {
#   vpc_id        = module.admin-vpc.vpc_id
#   peer_vpc_id   = module.app-vpc.vpc_id
#   auto_accept   = true
# }

# #Create peering between app and tfe
# resource "aws_vpc_peering_connection" "app_tfe" {
#   vpc_id        = module.app-vpc.vpc_id
#   peer_vpc_id   = module.tfe-vpc.vpc_id
#   auto_accept   = true
# }

resource "aws_default_security_group" "tfe-security-group" {
  #provider = data.aws_region.current.name
  vpc_id   = module.tfe-vpc.vpc_id

  ingress {
    protocol  = -1
    from_port = 0
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}