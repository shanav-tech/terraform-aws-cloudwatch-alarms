##---------------------------------------------------------------------------------------------------------------------------
## Provider block added, Use the Amazon Web Services (AWS) provider to interact with the many resources supported by AWS.
##--------------------------------------------------------------------------------------------------------------------------
provider "aws" {
  region = "us-east-1"
}

##---------------------------------------------------------------------------------------------------------------------------
## A VPC is a virtual network that closely resembles a traditional network that you'd operate in your own data center.
##--------------------------------------------------------------------------------------------------------------------------
module "vpc" {
  source      = "git::https://github.com/shanav-tech/terraform-aws-vpc.git?ref=v1.0.0"
  name        = "vpc"
  environment = "test"
  label_order = ["name", "environment"]
  cidr_block  = "172.16.0.0/16"
}

##-----------------------------------------------------
## A subnet is a range of IP addresses in your VPC.
##-----------------------------------------------------
module "public_subnets" {
  source      = "git::https://github.com/shanav-tech/terraform-aws-subnet.git?ref=v1.0.0"
  name        = "public-subnet"
  environment = "test"
  label_order = ["name", "environment"]

  availability_zones = ["us-east-1b", "us-east-1c"]
  vpc_id             = module.vpc.id
  cidr_block         = module.vpc.vpc_cidr_block
  ipv6_cidr_block    = module.vpc.ipv6_cidr_block
  type               = "public"
  igw_id             = module.vpc.igw_id
}

##-----------------------------------------------------
## Amazon EC2 provides cloud hosted virtual machines, called "instances", to run applications.
##-----------------------------------------------------
module "ec2" {
  source      = "git::https://github.com/shanav-tech/terraform-aws-ec2?ref=v1.0.0"
  name        = "ec2-instance"
  environment = "test"
  label_order = ["name", "environment"]

  ####----------------------------------------------------------------------------------
  ## Below A security group controls the traffic that is allowed to reach and leave the resources that it is associated with.
  ####----------------------------------------------------------------------------------
  vpc_id                      = module.vpc.id
  allowed_ip                  = [module.vpc.vpc_cidr_block]
  allowed_ports               = [22, 80, 443]
  instance_count              = 1
  ami                         = "ami-020cba7c55df1f615"
  ebs_optimized               = "false"
  instance_type               = "t2.nano"
  monitoring                  = true
  associate_public_ip_address = true
  tenancy                     = "default"
  subnet_ids                  = tolist(module.public_subnets.public_subnet_id)
  assign_eip_address          = "true"
  ebs_volume_enabled          = "true"
  ebs_volume_type             = "gp2"
  ebs_volume_size             = 30
  user_data                   = "./_bin/user_data.sh"
}

##-----------------------------------------------------------------------------
## alarm module call.
##-----------------------------------------------------------------------------
module "alarm" {
  source = "../../"

  name        = "alarm"
  environment = "test"
  label_order = ["name", "environment"]

  expression_enabled  = true
  alarm_name          = "cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = 40
  query_expressions = [{
    id          = "e1"
    expression  = "m2/m1*100"
    label       = "Error Rate"
    return_data = "true"
  }]
  query_metrics = [
    {
      id          = "m1"
      metric_name = "RequestCount"
      namespace   = "AWS/ApplicationELB"
      period      = "120"
      stat        = "Sum"
      unit        = "Count"
      return_data = null
      dimensions = {
        LoadBalancer = "app/web"
      }
      }, {
      id          = "m2"
      metric_name = "HTTPCode_ELB_5XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = "120"
      stat        = "Sum"
      unit        = "Count"
      return_data = null
      dimensions = {
        LoadBalancer = "app/web"
      }
  }]
  alarm_description         = "This metric monitors ec2 cpu utilization"
  alarm_actions             = []
  actions_enabled           = true
  insufficient_data_actions = []
  ok_actions                = []
}