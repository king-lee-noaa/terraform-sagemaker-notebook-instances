variable "region" {}
variable "domain_id" {}
variable "role_arn" {}
variable "root_access" {
    default = "Disabled"
}
variable "code_repositories" {
    type  = map(string)
}

variable "instance_type_01" {
    default = "ml.t3.medium"
}
variable "type_01_names" {
    type  = map(string)
}
variable "volume_size_01" {
    default = "5"
}

variable "instance_type_02" {
    default = "ml.t2.medium"
}
variable "type_02_names" {
    type  = map(string)
}
variable "volume_size_02" {
    default = "5"
}

variable "studio_lc_arns" {
    type  = map(string)
}
variable "user_names" {
    type  = map(string)
}