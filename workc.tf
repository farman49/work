########################################################################################################################
# Account VPC in Primary Region - IPAM CIDR
########################################################################################################################

locals {
  kms_key_id = "alias/${data.aws_caller_identity.this.account_id}-logs-key" #data.aws_kms_alias.logging.arn
}

data "aws_vpc_ipam_pool" "drs-dx-ipam-cidr-use1" {
  provider = aws.primary_region
  filter {
    name   = "description"
    values = ["drs-dx-ipam-cidr-use1"]
  }
}

data "aws_ec2_transit_gateway" "mufg-dx-use1-tgw" {
  provider = aws.primary_region
  filter {
    name   = "options.amazon-side-asn"
    values = ["64513"]
  }
}

data "aws_ec2_managed_prefix_list" "mufg-dx-cidr-use1" {
  provider = aws.primary_region
  filter {
    name   = "prefix-list-name"
    values = ["MUFG DX CIDR-s"]
  }
}

########################################################################################################################
# Staging
########################################################################################################################

module "primary_region_vpc" {
  providers = {
    aws   = aws.primary_region
  }
  source   = "aws-ia/vpc/aws"
  version = "~> 4.0.0"

  name       = "${data.aws_caller_identity.this.account_id}-staging"
  vpc_ipv4_ipam_pool_id = data.aws_vpc_ipam_pool.drs-dx-ipam-cidr-use1.id
  vpc_ipv4_netmask_length = 22
  az_count   = 3
  vpc_enable_dns_hostnames = true
  vpc_enable_dns_support = true

  transit_gateway_id = data.aws_ec2_transit_gateway.mufg-dx-use1-tgw.id
  transit_gateway_routes = {
    transit_gateway = data.aws_ec2_managed_prefix_list.mufg-dx-cidr-use1.id
  }

  subnets = {
    transit_gateway = {
      name_prefix  = "staging"
      netmask                                         = 27
      connect_to_public_natgw                         = true
      transit_gateway_appliance_mode_support          = "disable"
      transit_gateway_dns_support                     = "enable"
    }
  }
  vpc_flow_logs = var.vpc_flow_logs
}

########################################################################################################################
# 
########################################################################################################################

module "primary_region_vpc_recovery" {
  providers = {
    aws   = aws.primary_region
  }
  source   = "aws-ia/vpc/aws"
  version = "~> 4.0.0"

  name       = "${data.aws_caller_identity.this.account_id}-recovery"
  vpc_ipv4_ipam_pool_id = data.aws_vpc_ipam_pool.drs-dx-ipam-cidr-use1.id
  vpc_ipv4_netmask_length = 22
  az_count   = 3
  vpc_enable_dns_hostnames = true
  vpc_enable_dns_support = true

  transit_gateway_id = data.aws_ec2_transit_gateway.mufg-dx-use1-tgw.id
  transit_gateway_routes = {
    transit_gateway = data.aws_ec2_managed_prefix_list.mufg-dx-cidr-use1.id
  }

  subnets = {
    transit_gateway = {
      name_prefix  = "recovery"
      netmask                                         = 27
      connect_to_public_natgw                         = true
      transit_gateway_appliance_mode_support          = "disable"
      transit_gateway_dns_support                     = "enable"
    }
  }
  vpc_flow_logs = var.vpc_flow_logs
}

########################################################################################################################
# Account VPC in Secondary Region - IPAM CIDR
########################################################################################################################

data "aws_vpc_ipam_pool" "drs-dx-ipam-cidr-usw2" {
  filter {
    name   = "description"
    values = ["drs-dx-ipam-cidr-usw2"]
  }
}

data "aws_ec2_transit_gateway" "mufg-dx-usw2-tgw" {
  provider = aws.secondary_region
  filter {
    name   = "options.amazon-side-asn"
    values = ["64514"]
  }
}

data "aws_ec2_managed_prefix_list" "mufg-dx-cidr-usw2" {
  provider = aws.secondary_region
  filter {
    name   = "prefix-list-name"
    values = ["MUFG DX CIDR-s"]
  }
}

module "secondary_region_vpc" {
  providers = {
    aws   = aws.secondary_region
  }
  source   = "aws-ia/vpc/aws"
  version = "~> 4.0.0"

  name       = "${data.aws_caller_identity.this.account_id}-staging"
  vpc_ipv4_ipam_pool_id = data.aws_vpc_ipam_pool.drs-dx-ipam-cidr-usw2.id
  vpc_ipv4_netmask_length = 22
  az_count   = 3
  vpc_enable_dns_hostnames = true
  vpc_enable_dns_support = true

  transit_gateway_id = data.aws_ec2_transit_gateway.mufg-dx-usw2-tgw.id
  transit_gateway_routes = {
    transit_gateway = data.aws_ec2_managed_prefix_list.mufg-dx-cidr-usw2.id
  }

  subnets = {
    transit_gateway = {
      name_prefix  = "staging"
      netmask                                         = 27
      connect_to_public_natgw                         = true
      transit_gateway_appliance_mode_support          = "disable"
      transit_gateway_dns_support                     = "enable"
    }
  }
  vpc_flow_logs = var.vpc_flow_logs
}

########################################################################################################################
# 
########################################################################################################################

module "secondary_region_vpc_recovery" {
  providers = {
    aws   = aws.secondary_region
  }
  source   = "aws-ia/vpc/aws"
  version = "~> 4.0.0"

  name       = "${data.aws_caller_identity.this.account_id}-recovery"
  vpc_ipv4_ipam_pool_id = data.aws_vpc_ipam_pool.drs-dx-ipam-cidr-usw2.id
  vpc_ipv4_netmask_length = 22
  az_count   = 3
  vpc_enable_dns_hostnames = true
  vpc_enable_dns_support = true

  transit_gateway_id = data.aws_ec2_transit_gateway.mufg-dx-usw2-tgw.id
  transit_gateway_routes = {
    transit_gateway = data.aws_ec2_managed_prefix_list.mufg-dx-cidr-usw2.id
  }

  subnets = {
    transit_gateway = {
      name_prefix  = "recovery"
      netmask                                         = 27
      connect_to_public_natgw                         = true
      transit_gateway_appliance_mode_support          = "disable"
      transit_gateway_dns_support                     = "enable"
    }
  }
  vpc_flow_logs = var.vpc_flow_logs
}
