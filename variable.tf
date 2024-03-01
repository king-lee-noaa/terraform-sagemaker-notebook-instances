variable "region" {}
variable "instance_type" {
    default = "ml.t3.medium"
}
variable "notebook_name" {
    default = "default-instance-terraform"
}
variable "role_arn" {}
variable "volume_size" {
    default = "5"
}
variable "instance_count" {
    default = "1"
}
variable "root_access" {
    default = "Disabled"
}
variable "domain_id" {}
variable "user_names" {}