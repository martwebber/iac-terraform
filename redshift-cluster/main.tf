data "aws_vpcs" "all" {}

data "aws_vpc" "default" {
  count   = length(data.aws_vpcs.all.ids)
  id      = data.aws_vpcs.all.ids[count.index]
  default = true
}

data "aws_subnets" "example" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default[0].id]
  }
}

data "aws_subnet" "example" {
  for_each = toset(data.aws_subnets.example.ids)
  id       = each.value

}

resource "aws_redshift_subnet_group" "redshift_subnet_group" {
  name       = var.redshift_subnet_group_name
  subnet_ids = [for subn in data.aws_subnet.example : subn.id]
  tags = merge(
    var.tags,
    {
      Name = "${var.region}-${var.project}-redshift-subnet-group"
    },
  )
}

resource "aws_iam_role" "s3_read_role" {
  name = var.s3_read_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_policy" "s3_read_policy" {
  name        = var.s3_read_policy_name
  description = var.s3_read_policy_description

  policy = file("./policy.json")
}

resource "aws_iam_role_policy_attachment" "s3_read_role_attachment" {
  policy_arn = aws_iam_policy.s3_read_policy.arn
  role       = aws_iam_role.s3_read_role.name
}


resource "aws_security_group" "sg" {
  name        = var.security_group_name
  description = var.security_group_description
  vpc_id      = data.aws_vpcs.all.ids[0]

  ingress {
    description      = var.security_group_ingress_description
    from_port        = var.redshift_cluster_port
    to_port          = var.redshift_cluster_port
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.region}-${var.project}-security-group"
    },
  )
}


resource "aws_redshift_cluster" "redshift_cluster" {
  cluster_identifier = var.redshift_cluster_identifier
  database_name      = var.database_name
  master_username    = var.master_username
  master_password    = var.master_password
  node_type          = var.node_type
  cluster_type       = var.cluster_type
  skip_final_snapshot = var.final_snapshot
  cluster_subnet_group_name = aws_redshift_subnet_group.redshift_subnet_group.name
  vpc_security_group_ids = [aws_security_group.sg.id]
  iam_roles = [aws_iam_role.s3_read_role.arn]
  enhanced_vpc_routing = var.cluster_enhanced_vpc_routing
  publicly_accessible = var.cluster_publicly_accessible
  encrypted = var.cluster_data_encryption
  number_of_nodes = var.number_of_nodes
  port = var.redshift_cluster_port
  tags = merge(
    var.tags,
    {
      Name = "${var.region}-${var.project}-redhift-cluster"
    },
  )
}

























# resource "aws_iam_policy" "my_s3_readonly_policy_redshift" {
#   name   = var.s3_policy_name
#   policy = file("./policy.json")

# #   tags = merge(
# #     var.tags,
# #     {
# #       Name = "${var.region}-${var.project}-policy"
# #     },
# #   )
# }



# resource "aws_iam_role" "my_s3_readonly_policy_redshift" {
#   name = "redshift-role"

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   assume_role_policy = file("./policy.json")

#   tags = {
#     tag-key = "tag-value"
#   }
# }








# data "aws_subnet_ids" "default" {
#   vpc_id = data.aws_vpcs.all.ids[0]  # Assuming the first VPC is the default one
# }

# output "subnet_ids" {
#   value = data.aws_subnet_ids.default.ids
# }




# data "aws_subnet_ids" "test_subnet_ids" {
#   vpc_id = "default"
# }
# data "aws_subnet" "test_subnet" {
#   count = "${length(data.aws_subnet_ids.test_subnet_ids.ids)}"
#   id    = "${tolist(data.aws_subnet_ids.test_subnet_ids.ids)[count.index]}"
# }

# output "subnet_cidr_blocks" {
#   value = ["${data.aws_subnet.test_subnet.*.id}"]
# }