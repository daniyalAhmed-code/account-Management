locals {
  RESOURCE_PREFIX = "${lower(var.ENV)}-cc-customer-actmgmt-aws"
  DYNAMO_DB_ACCOUNTS_TABLE_NAME =  "${lower(var.ENV)}-accounts-aws-{{cuid}}"
  DATA_TENANTS_SOURCE_BUCKET_PATH_TEMPLATE = "{{cuid}}.cc-data/{{cuid}}.cc-aws-data/{{ouid}}/{{cuid}}.cc-aws-data-awsorgz/"
  DATA_TENANTS_BUCKET_NAME = "${lower(var.ENV)}-cc-data-tenants"
  DYNAMO_DB_ONBOARDING_TABLE_NAME = "${lower(var.ENV)}-cc-onboard-aws-customerid"
  DYNAMO_DB_ENTITY_TABLE_NAME = "entity-{{cuid}}"
  DYNAMO_DB_CUSTOMER_TABLE = "${lower(var.ENV)}-customerid"
  LAMBDA_AUTHORIZER_INVOKE_ARN = "ABC"#"${data.terraform_remote_state.api_core_remote_state.outputs.cecurecloud_api_req_entity_auth_lambda_invoke_arn}"
 
  MAIL_TEMPLATE_BUCKET = "${lower(var.ENV)}-cc-api-core-mail-templates"
}

module "Role" {
  source = "./modules/Role"

  RESOURCE_PREFIX = "${local.RESOURCE_PREFIX}"
}

module "Policies" {
  source = "./modules/Policies"

  RESOURCE_PREFIX = "${local.RESOURCE_PREFIX}"
  LAMBDA_ROLE_NAME = "${module.Role.LAMBDA_ROLE_NAME}"
  CURRENT_ACCOUNT_ID = "${data.aws_caller_identity.current.account_id}"
  IAM_ASSUMABLE_ROLE_NAME = "${var.IAM_ASSUMABLE_ROLE_NAME}"
  AWS_REGION = "${data.aws_region.current.name}"
  MAIL_TEMPLATE_BUCKET = "${local.MAIL_TEMPLATE_BUCKET}"
}

module "Lambda" {
  source = "./modules/Lambda"

  LAMBDA_ROLE_ARN = "${module.Role.LAMBDA_ROLE_ARN}"
  RESOURCE_PREFIX = "${local.RESOURCE_PREFIX}"
  IAM_ASSUMABLE_ROLE_NAME = "${var.IAM_ASSUMABLE_ROLE_NAME}"
  DYNAMO_DB_ACCOUNTS_TABLE_NAME = "${local.DYNAMO_DB_ACCOUNTS_TABLE_NAME}"
  DATA_TENANTS_SOURCE_BUCKET_PATH_TEMPLATE = "${local.DATA_TENANTS_SOURCE_BUCKET_PATH_TEMPLATE}"
  DATA_TENANTS_BUCKET_NAME = "${local.DATA_TENANTS_BUCKET_NAME}"
  DYNAMO_DB_ONBOARDING_TABLE_NAME = "${local.DYNAMO_DB_ONBOARDING_TABLE_NAME}"
  
  DYNAMO_DB_ENTITY_TABLE_NAME = "${local.DYNAMO_DB_ENTITY_TABLE_NAME}"
  NOTIFICATION_EMAIL_SENDER = "${var.NOTIFICATION_EMAIL_SENDER}"
  DYNAMO_DB_CUSTOMER_TABLE = "${local.DYNAMO_DB_CUSTOMER_TABLE}"
  SUPPORT_EMAIL = "${var.SUPPORT_EMAIL}"
  LINKDIN_ICON_HYPERLINK = "${var.LINKDIN_ICON_HYPERLINK}"
  TWITTER_ICON_HYPERLINK = "${var.TWITTER_ICON_HYPERLINK}"
  WESTMYRA_ICON_HYPERLINK = "${var.WESTMYRA_ICON_HYPERLINK}"
  MAIL_TEMPLATE_BUCKET = "${local.MAIL_TEMPLATE_BUCKET}"
  
  ENV = "${var.ENV}"
}

module "API" {
  source = "./modules/API"
  RESOURCE_PREFIX = "${local.RESOURCE_PREFIX}"
  AWS_LAMBDA_UPDATE_ACCOUNTS_TABLE_NAME = "${data.terraform_remote_state.api_aws_remote_state.outputs.UPDATE_ACCOUNT_FUNCTION}"
  AWS_LAMBDA_UPDATE_ACCOUNTS_TABLE_INVOKE_ARN = "${data.terraform_remote_state.api_aws_remote_state.outputs.UPDATE_ACCOUNT_ARN}"
  AWS_LAMBDA_GET_ACCOUNT_INFO_NAME = "${data.terraform_remote_state.api_aws_remote_state.outputs.GET_ACCOUNT_FUNCTION}"
  AWS_LAMBDA_GET_ACCOUNT_INFO_INVOKE_ARN = "${data.terraform_remote_state.api_aws_remote_state.outputs.GET_ACCOUNT_ARN}"
  AWS_LAMBDA_LIST_CUST_ACCOUNTS_NAME = "${data.terraform_remote_state.api_aws_remote_state.outputs.LIST_ACCOUNT_FUNCTION}"
  AWS_LAMBDA_LIST_CUST_ACCOUNTS_INVOKE_ARN = "${data.terraform_remote_state.api_aws_remote_state.outputs.LIST_ACCOUNT_ARN}"

  GCP_LAMBDA_UPDATE_ACCOUNTS_TABLE_NAME = "${data.terraform_remote_state.api_gcp_remote_state.outputs.GCP_UPDATE_ACCOUNT_FUNCTION}"
  GCP_LAMBDA_UPDATE_ACCOUNTS_TABLE_INVOKE_ARN = "${data.terraform_remote_state.api_gcp_remote_state.outputs.GCP_UPDATE_ACCOUNT_ARN}"
  GCP_LAMBDA_GET_ACCOUNT_INFO_NAME = "${data.terraform_remote_state.api_gcp_remote_state.outputs.GCP_GET_ACCOUNT_FUNCTION}"
  GCP_LAMBDA_GET_ACCOUNT_INFO_INVOKE_ARN = "${data.terraform_remote_state.api_gcp_remote_state.outputs.GCP_GET_ACCOUNT_ARN}"
  GCP_LAMBDA_LIST_CUST_ACCOUNTS_NAME = "${data.terraform_remote_state.api_gcp_remote_state.outputs.GCP_LIST_ACCOUNT_FUNCTION}"
  GCP_LAMBDA_LIST_CUST_ACCOUNTS_INVOKE_ARN = "${data.terraform_remote_state.api_gcp_remote_state.outputs.GCP_LIST_ACCOUNT_ARN}"


  # LAMBDA_AUTHORIZER_INVOKE_ARN = "${local.LAMBDA_AUTHORIZER_INVOKE_ARN}"
  LAMBDA_AUTHORIZER_INVOKE_ARN = "${module.Lambda.LAMBDA_AUTHORIZER_INVOKE_ARN}"
  LAMBDA_ROLE_ARN = "${module.Role.LAMBDA_ROLE_ARN}"
  ENV = "${var.ENV}"
}

