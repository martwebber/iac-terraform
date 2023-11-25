# data "aws_vpc" "default" {
#   id = var.vpc_id
# }

# output "vpc_id" {
#   value = data.aws_vpc.default
# }

# data "aws_vpcs" "all" {}

# data "aws_vpc" "default" {
#   count   = length(data.aws_vpcs.all.ids)
#   id      = data.aws_vpcs.all.ids[count.index]
#   default = true
# }

# output "default_vpc_id" {
#   value = data.aws_vpc.default[0].id
# }


