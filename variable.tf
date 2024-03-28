variable "region" {}
variable "instance_type_01" {
    default = "ml.t3.medium"
}
variable "type_01_names" {}
variable "instance_type_02" {
    default = "ml.t2.medium"
}
variable "type_02_names" {}
variable "role_arn" {}
variable "volume_size" {
    default = "5"
}
variable "root_access" {
    default = "Disabled"
}
variable "domain_id" {}
variable "user_names" {}
variable "studio_lc_arn" {}