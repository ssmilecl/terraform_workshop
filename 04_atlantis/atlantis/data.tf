# Get VPC by tag
data "aws_vpc" "atlantis" {
  id = var.vpc_id
}

# Get private subnets
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.atlantis.id]
  }

  tags = {
    Name = "*private*" # This matches the naming pattern from vpc module
  }
}

# Get public subnets
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.atlantis.id]
  }

  tags = {
    Name = "*public*" # This matches the naming pattern from vpc module
  }
}

# Get subnet details for AZs
data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

# Fetch existing SSM Parameters
data "aws_ssm_parameter" "github_token" {
  name = "/atlantis/github/token"
}

data "aws_ssm_parameter" "webhook_secret" {
  name = "/atlantis/github/webhook-secret"
}
