provider "aws" {
  region = "eu-west-1"
}

locals {
  userdata = templatefile("userdata.sh", {
    ssm_cloudwatch_config = aws_ssm_parameter.cw_agent.name
  })
}

resource "aws_instance" "this" {
  ami                  = "ami-096f43ef67d75e998"
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.this.name
  security_groups      = ["web-node"]
  user_data            = local.userdata
  key_name             = "MyKey"
  tags                 = { Name = "EC2-with-cw-agent" }
  credit_specification {
    cpu_credits = "standard"
  }
}

resource "aws_ssm_parameter" "cw_agent" {
  description = "Cloudwatch agent config to configure custom log"
  name        = "/cloudwatch-agent/config"
  type        = "String"
  value       = file("cw_agent_config.json")
}

resource "aws_cloudwatch_log_group" "LogGroup_1" {
  // name - (Optional, Forces new resource) The name of the log group. If omitted, Terraform will assign a random, unique name.
  name = "application_logs"
  // name_prefix - (Optional, Forces new resource) Creates a unique name beginning with the specified prefix. Conflicts with name.
  // name_prefix = "Autentia application logs"

  // retention_in_days - (Optional) Specifies the number of days you want to retain log events in the specified log group.
  // Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. 
  // If you select 0, the events in the log group are always retained and never expire.
  retention_in_days = 1

  // kms_key_id - (Optional) The ARN of the KMS Key to use when encrypting log data. Please note, after the AWS KMS CMK is disassociated from the log group, AWS CloudWatch Logs stops encrypting newly ingested data for the log group. All previously ingested data remains encrypted, and AWS CloudWatch Logs requires permissions for the CMK whenever the encrypted data is requested.
  //kms_key_id = "log_cypher_key"

  // tags - (Optional) A map of tags to assign to the resource.
  tags = {
    Environment = "production"
    Application = "AWS Tutorial"
  }
}

resource "aws_cloudwatch_log_stream" "syslog" {
  // name - (Required) The name of the log stream. Must not be longer than 512 characters and must not contain :
  name = "Syslog"
  // log_group_name - (Required) The name of the log group under which the log stream is to be created.
  log_group_name = aws_cloudwatch_log_group.LogGroup_1.name
}

resource "aws_cloudwatch_log_stream" "cloudwatchlogs" {
  // name - (Required) The name of the log stream. Must not be longer than 512 characters and must not contain :
  name = "Cloudwatch"
  // log_group_name - (Required) The name of the log group under which the log stream is to be created.
  log_group_name = aws_cloudwatch_log_group.LogGroup_1.name
}
