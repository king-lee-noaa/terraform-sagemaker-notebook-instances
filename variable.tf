variable "region" {}
variable "instance_type_01" {
    default = "ml.t3.medium"
}
variable "type_01_names" {}
variable "volume_size_01" {
    default = "5"
}
variable "instance_type_02" {
    default = "ml.t2.medium"
}
variable "type_02_names" {}
variable "volume_size_02" {
    default = "5"
}
variable "role_arn" {}
variable "root_access" {
    default = "Disabled"
}
variable "domain_id" {}
variable "user_names" {}
variable "studio_lc_arn" {}