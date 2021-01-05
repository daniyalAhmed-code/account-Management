data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "terraform_remote_state" "api_aws_remote_state" {
  backend   = "s3"
  config = {
    bucket  = "daniyal-terraform-remote-state-centralised"
    key     = "daniyal-actmgmt-aws/{{ENV}}/terraform.tfstate"
    region  = "us-east-2"   
  }
}

data "terraform_remote_state" "api_gcp_remote_state" {
  backend   = "s3"
  config = {
    bucket  = "daniyal-terraform-remote-state-centralised"
    key     = "daniyal-actmgmt-gcp/{{ENV}}/terraform.tfstate"
    region  = "us-east-2"   
  }
}