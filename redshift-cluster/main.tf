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

resource "aws_iam_role" "redshift_role" {
  name = var.redshift_role_name

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
        ],
        "Principal" : {
          "Service" : [
            "redshift.amazonaws.com"
          ]
        }
      }
    ]
  })
}

resource "aws_iam_policy" "s3_read_policy" {
  name        = var.s3_read_policy_name
  description = var.s3_read_policy_description

  policy = file("./policy.json")
}

resource "aws_iam_role_policy_attachment" "redshift_role_attachment" {
  policy_arn = aws_iam_policy.s3_read_policy.arn
  role       = aws_iam_role.redshift_role.name
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
  cluster_identifier        = var.redshift_cluster_identifier
  database_name             = var.database_name
  master_username           = var.master_username
  master_password           = var.master_password
  node_type                 = var.node_type
  cluster_type              = var.cluster_type
  skip_final_snapshot       = var.final_snapshot
  cluster_subnet_group_name = aws_redshift_subnet_group.redshift_subnet_group.name
  vpc_security_group_ids    = [aws_security_group.sg.id]
  iam_roles                 = [aws_iam_role.redshift_role.arn]
  enhanced_vpc_routing      = var.cluster_enhanced_vpc_routing
  publicly_accessible       = var.cluster_publicly_accessible
  encrypted                 = var.cluster_data_encryption
  number_of_nodes           = var.number_of_nodes
  port                      = var.redshift_cluster_port
  tags = merge(
    var.tags,
    {
      Name = "${var.region}-${var.project}-redhift-cluster"
    },
  )
}
