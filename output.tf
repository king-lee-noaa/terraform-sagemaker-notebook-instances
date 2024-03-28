output "aws_sagemaker_notebook_instance_lifecycle" {
    value = aws_sagemaker_notebook_instance_lifecycle_configuration.sagemaker_nbi_lc.name
}

output "aws_sagemaker_notebook_type_01_names" {
    value = values(aws_sagemaker_notebook_instance.sagemaker_nbi_type_01).*.name
}

output "aws_sagemaker_notebook_type_02_names" {
    value = values(aws_sagemaker_notebook_instance.sagemaker_nbi_type_02).*.name
}

output "aws_sagemaker_user_profile_names" {
    value = values(aws_sagemaker_user_profile.user_profile).*.user_profile_name
}
