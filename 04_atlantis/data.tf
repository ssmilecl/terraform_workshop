# Get VPC by tag
data "aws_vpc" "atlantis" {
  tags = {
    Name = "atlantis-vpc" # This should match the VPC name from vpc/main.tf
  }
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
