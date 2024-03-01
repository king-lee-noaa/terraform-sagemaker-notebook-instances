# -------------------------------------
# SageMaker Creation
# note: windows LF can cause problem on the on_create script.  Run the following to fix:
# $ sed -i -e 's/\r$//' main.tf
#
# note: scripts/auto-stop-idle/on-start.sh to stop instances idle for 1 hour
# https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/blob/master/scripts/auto-stop-idle/on-start.sh
# -------------------------------------

resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "sagemaker_nbi_lc" {
  name      = "nbi-lifecycle"
  on_create = base64encode(<<-EOF
                #!/usr/bin/bash
                git clone https://github.com/king-lee-noaa/learning-journey.git /home/ec2-user/SageMaker/learning-journey -b notebook-instance
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

resource "aws_sagemaker_notebook_instance" "sagemaker_nbi" {
  count = var.instance_count
  name          = "${var.notebook_name}-${format("%02d", count.index + 1)}"
  role_arn      = var.role_arn
  instance_type = var.instance_type
  volume_size = var.volume_size
  lifecycle_config_name = aws_sagemaker_notebook_instance_lifecycle_configuration.sagemaker_nbi_lc.name
  root_access   = var.root_access

  tags = {
    "Name" = "sagemaker_notebook_instance-${format("%02d", count.index + 1)}"
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
}

resource "aws_sagemaker_notebook_instance" "sagemaker_nbi_gpu" {
  count = var.instance_count
  name          = "${var.notebook_name}-gpu-${format("%02d", count.index + 1)}"
  role_arn      = var.role_arn
  instance_type = var.gpu_instance_type
  volume_size = var.volume_size
  lifecycle_config_name = aws_sagemaker_notebook_instance_lifecycle_configuration.sagemaker_nbi_lc.name
  root_access   = var.root_access

  tags = {
    "Name" = "sagemaker_notebook_gpu_instance-${format("%02d", count.index + 1)}"
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
}

resource "aws_sagemaker_user_profile" "user_profile" {
  for_each = toset(var.user_names)
  domain_id = var.domain_id
  user_profile_name = each.key
  user_settings {
    execution_role  = var.role_arn
  }
}