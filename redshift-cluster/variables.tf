variable "project" {
  description = "Project name"
  type        = string
}

variable "region" {
  description = "Region to deploy resources in"
  type        = string
}

variable "redshift_cluster_identifier" {
  description = "Redshift cluster identifier - This is a required field, and must be a lower case string."
  type        = string
}

variable "database_name" {
  description = "database name"
  type        = string
}

variable "master_username" {
  description = "Master usename"
  type        = string
}

variable "master_password" {
  description = "Master password"
  type        = string
}

variable "node_type" {
  description = "node type"
  type        = string
}

variable "cluster_type" {
  description = "cluster type"
  type        = string
}

variable "s3_policy_name" {
  description = "S3 read only access policy"
  type = string
}

variable "cluster_subnet_group_name" {
  description = "Cluster subnet group name"
  type = string
}

variable "cluster_vpc_security_group_ids" {
  description = "A list of security groups"
  type = list(any)
}

variable "cluster_iam_roles" {
  description = "A list of IAM roles"
  type = list(any)
}

variable "cluster_enhanced_vpc_routing" {
  description = "Enhanced vpc routing"
  type = bool
}

variable "cluster_publicly_accessible" {
  description = "Cluster public accessibility"
  type = bool
}

variable "cluster_data_encryption" {
  description = "Data encryption"
  type = bool
}

variable "redshift_cluster_port" {
  description = "Cluster port"
  type = number
}

variable "number_of_nodes" {
  description = "Cluster subnet group name"
  type = number
}

variable "final_snapshot" {
  description = "Final snapshot"
  type = bool
}

variable "security_group_name" {
  description = "Security group name"
  type = string
}

variable "security_group_description" {
  description = "Security group description"
  type = string
}

variable "security_group_ingress_description" {
  description = "Security group ingres description"
  type = string
}

variable "redshift_subnet_group_name" {
  description = "Redshift subnet group name"
  type = string
}

variable "s3_read_role_name" {
  description = "S3 read role name"
  type = string
}

variable "s3_read_policy_name" {
  description = "S3 read policy name"
  type = string
}

variable "s3_read_policy_description" {
  description = "S3 read policy description"
  type = string
}

variable "tags" {
  description = "Tags to be used in the project"
  type        = map(any)
  default     = {}
}

