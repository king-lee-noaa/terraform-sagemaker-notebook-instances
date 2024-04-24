# -------------------------------------
# SageMaker Creation
# note: windows LF can cause problem on the on_create script.  Run the following to fix:
# $ sed -i -e 's/\r$//' main.tf
#
# note: scripts/auto-stop-idle/on-start.sh to stop instances idle for 1 hour
# https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/blob/master/scripts/auto-stop-idle/on-start.sh
# -------------------------------------

resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "sagemaker_nbi_lc" {
  for_each  = var.code_repositories
  name      = "nbi-lifecycle-${each.key}"
  on_create = base64encode(<<-EOF
                #!/usr/bin/bash
                
                sudo -i -u ec2-user git clone "${each.value}" "SageMaker/AmazonSageMaker-${each.key}"
                
              EOF
              )
  on_start  = base64encode(<<-EOF
                #!/usr/bin/bash

                set -ex

                # OVERVIEW
                # This script stops a SageMaker notebook once it's idle for more than 1 hour (default time)
                # You can change the idle time for stop using the environment variable below.
                # If you want the notebook the stop only if no browsers are open, remove the --ignore-connections flag
                #
                # Note that this script will fail if either condition is not met
                #   1. Ensure the Notebook Instance has internet connectivity to fetch the example config
                #   2. Ensure the Notebook Instance execution role permissions to SageMaker:StopNotebookInstance to stop the notebook 
                #       and SageMaker:DescribeNotebookInstance to describe the notebook.
                #

                # PARAMETERS
                IDLE_TIME=3600

                echo "Fetching the autostop script"
                wget https://raw.githubusercontent.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/master/scripts/auto-stop-idle/autostop.py


                echo "Detecting Python install with boto3 install"

                # Find which install has boto3 and use that to run the cron command. So will use default when available
                # Redirect stderr as it is unneeded
                CONDA_PYTHON_DIR=$(source /home/ec2-user/anaconda3/bin/activate /home/ec2-user/anaconda3/envs/JupyterSystemEnv && which python)
                if $CONDA_PYTHON_DIR -c "import boto3" 2>/dev/null; then
                    PYTHON_DIR=$CONDA_PYTHON_DIR
                elif /usr/bin/python -c "import boto3" 2>/dev/null; then
                    PYTHON_DIR='/usr/bin/python'
                else
                    # If no boto3 just quit because the script won't work
                    echo "No boto3 found in Python or Python3. Exiting..."
                    exit 1
                fi

                echo "Found boto3 at $PYTHON_DIR"


                echo "Starting the SageMaker autostop script in cron"

                (crontab -l 2>/dev/null; echo "*/5 * * * * $PYTHON_DIR $PWD/autostop.py --time $IDLE_TIME --ignore-connections >> /var/log/jupyter.log") | crontab -
              EOF
              )
}

resource "aws_sagemaker_notebook_instance" "sagemaker_nbi_type_01" {
  for_each = var.type_01_names
  name          = each.key
  role_arn      = var.role_arn
  instance_type = var.instance_type_01
  volume_size = var.volume_size_01
  lifecycle_config_name = aws_sagemaker_notebook_instance_lifecycle_configuration.sagemaker_nbi_lc["${each.value}"].name
  root_access   = var.root_access
  subnet_id     = var.subnet_id
  security_groups = var.security_groups
  direct_internet_access = var.direct_internet_access
  kms_key_id    = var.kms_key_id
  
  tags = {
    "Name" = each.key
    "noaa:taskorder" = "gs-35f-131ca"
    "noaa:fismaid" = "noaa5006"
    "nccf:cost:provider" = "ncai"
    "nccf:ssbox:project" = "ingest"
    "nccf:ssbox:org" = "ncai"
    "noaa:environment" = "ssbox"
    "nccf:cost:function" = "work"
    "noaa:lineoffice" = "nesdis"
    "noaa:programoffice" = "40-02"
    "nccf:cost:mission" = "ncai"
  }
  
  depends_on = [
    aws_sagemaker_notebook_instance_lifecycle_configuration.sagemaker_nbi_lc
  ]
}

resource "aws_sagemaker_notebook_instance" "sagemaker_nbi_type_02" {
  for_each = var.type_02_names
  name          = each.key
  role_arn      = var.role_arn
  instance_type = var.instance_type_02
  volume_size = var.volume_size_02
  lifecycle_config_name = aws_sagemaker_notebook_instance_lifecycle_configuration.sagemaker_nbi_lc["${each.value}"].name
  root_access   = var.root_access
  subnet_id     = var.subnet_id
  security_groups = var.security_groups
  direct_internet_access = var.direct_internet_access
  kms_key_id    = var.kms_key_id

  tags = {
    "Name" = each.key
    "noaa:taskorder" = "gs-35f-131ca"
    "noaa:fismaid" = "noaa5006"
    "nccf:cost:provider" = "ncai"
    "nccf:ssbox:project" = "ingest"
    "nccf:ssbox:org" = "ncai"
    "noaa:environment" = "ssbox"
    "nccf:cost:function" = "work"
    "noaa:lineoffice" = "nesdis"
    "noaa:programoffice" = "40-02"
    "nccf:cost:mission" = "ncai"
  }
  
  depends_on = [
    aws_sagemaker_notebook_instance_lifecycle_configuration.sagemaker_nbi_lc
  ]
}

resource "aws_sagemaker_user_profile" "user_profile" {
  for_each = var.user_names
  domain_id = var.domain_id
  user_profile_name = each.key
  user_settings {
    execution_role  = var.role_arn
    jupyter_server_app_settings {
        default_resource_spec {
          lifecycle_config_arn = var.studio_lc_arns[each.value]
        }
        lifecycle_config_arns = [ var.studio_lc_arns[each.value] ]
    }
  }
}