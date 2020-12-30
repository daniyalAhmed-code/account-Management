resource "aws_lambda_layer_version" "share_python_lib" {
  layer_name = "${var.RESOURCE_PREFIX}-shared-lib-python"
  filename   = "${path.module}/layers/shared_lib.zip"
  source_code_hash = "${filebase64sha256("${path.module}/layers/shared_lib.zip")}"
}

resource "aws_lambda_function" "lambda_parse_org_data" {
  filename         = "${path.module}/code/zip/parse-org-data.zip"
  function_name    = "${var.RESOURCE_PREFIX}-parse-org-data"
  role             = "${var.LAMBDA_ROLE_ARN}"
  handler          = "parse-org-data.lambda_handler"
  source_code_hash = "${data.archive_file.lambda_parse_org_data_archive.output_base64sha256}"
  runtime          = "python3.8"
  timeout          = "900"
  environment {
    variables = {
      DATA_TENANTS_BUCKET_NAME = "${var.DATA_TENANTS_BUCKET_NAME}"
      DATA_TENANTS_SOURCE_BUCKET_PATH_TEMPLATE = "${var.DATA_TENANTS_SOURCE_BUCKET_PATH_TEMPLATE}"
      DYNAMO_DB_ACCOUNTS_TABLE_NAME = "${var.DYNAMO_DB_ACCOUNTS_TABLE_NAME}"
      IAM_ASSUMABLE_ROLE_NAME = "${var.IAM_ASSUMABLE_ROLE_NAME}"
      DYNAMO_DB_ONBOARDING_TABLE_NAME = "${var.DYNAMO_DB_ONBOARDING_TABLE_NAME}"
    }
  }
}

resource "aws_lambda_function" "lambda_traverse_cust_for_org_account" {
  filename         = "${path.module}/code/zip/traverse-cust-for-org-account.zip"
  function_name    = "${var.RESOURCE_PREFIX}-traverse-cust-for-org-account"
  role             = "${var.LAMBDA_ROLE_ARN}"
  handler          = "traverse-cust-for-org-account.lambda_handler"
  source_code_hash = "${data.archive_file.lambda_traverse_cust_for_org_account_archive.output_base64sha256}"
  runtime          = "python3.8"
  timeout          = "900"
  environment {
    variables = {
      onBoardingTableName = "${var.DYNAMO_DB_ONBOARDING_TABLE_NAME}"
      lambdaParseS3DataName = "${aws_lambda_function.lambda_parse_org_data.function_name}"
    }
  }
}

resource "aws_lambda_function" "lambda_update_accounts_table" {
  filename         = "${path.module}/code/zip/update-accounts-table.zip"
  function_name    = "${var.RESOURCE_PREFIX}-update-accounts-table"
  role             = "${var.LAMBDA_ROLE_ARN}"
  handler          = "update-accounts-table.lambda_handler"
  source_code_hash = "${data.archive_file.lambda_update_accounts_table_archive.output_base64sha256}"
  runtime          = "python3.8"
  timeout          = "900"
  environment {
    variables = {
      MAIL_TEMPLATE_BUCKET = "${var.MAIL_TEMPLATE_BUCKET}"
      SUPPORT_EMAIL = "${var.SUPPORT_EMAIL}"
      LINKDIN_ICON_HYPERLINK = "${var.LINKDIN_ICON_HYPERLINK}"
      TWITTER_ICON_HYPERLINK = "${var.TWITTER_ICON_HYPERLINK}"
      WESTMYRA_ICON_HYPERLINK = "${var.WESTMYRA_ICON_HYPERLINK}"
      notificationEmailSender = "${var.NOTIFICATION_EMAIL_SENDER}"
      entityTableName = "${var.DYNAMO_DB_ENTITY_TABLE_NAME}"
      customerTableName = "${var.DYNAMO_DB_CUSTOMER_TABLE}"
      DYNAMO_DB_ACCOUNTS_TABLE_NAME = "${var.DYNAMO_DB_ACCOUNTS_TABLE_NAME}"
    }
  }
  layers = ["${aws_lambda_layer_version.share_python_lib.arn}"]
}

resource "aws_lambda_function" "lambda_get_account_info" {
  filename         = "${path.module}/code/zip/get-account-info.zip"
  function_name    = "${var.RESOURCE_PREFIX}-get-account-info"
  role             = "${var.LAMBDA_ROLE_ARN}"
  handler          = "get-account-info.lambda_handler"
  source_code_hash = "${data.archive_file.lambda_get_account_info_archive.output_base64sha256}"
  runtime          = "python3.8"
  timeout          = "900"
  environment {
    variables = {
      DYNAMO_DB_ACCOUNTS_TABLE_NAME = "${var.DYNAMO_DB_ACCOUNTS_TABLE_NAME}"
    }
  }
}

resource "aws_lambda_function" "lambda_list_cust_accounts" {
  filename         = "${path.module}/code/zip/list-cust-accounts.zip"
  function_name    = "${var.RESOURCE_PREFIX}-list-cust-accounts"
  role             = "${var.LAMBDA_ROLE_ARN}"
  handler          = "list-cust-accounts.lambda_handler"
  source_code_hash = "${data.archive_file.lambda_list_cust_accounts_archive.output_base64sha256}"
  runtime          = "python3.8"
  timeout          = "900"
  environment {
    variables = {
      DYNAMO_DB_ACCOUNTS_TABLE_NAME = "${var.DYNAMO_DB_ACCOUNTS_TABLE_NAME}"
      DYNAMO_DB_ENTITY_TABLE_NAME = "${var.DYNAMO_DB_ENTITY_TABLE_NAME}"
    }
  }
}



resource "aws_lambda_function" "lambda_customer_key_authorizer" {
  filename         = "${path.module}/code/zip/0a-customer-key-authorizer.zip"
  function_name    = "${var.RESOURCE_PREFIX}-customer_key_authorizer"
  role             = "${var.LAMBDA_ROLE_ARN}"
  handler          = "customer-key-authorizer.handler"
  source_code_hash = "${data.archive_file.lambda_customer_key_authorizer_archive.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "900"
  environment {
    variables = {
      STAGE = "${var.ENV}"
    }
  }
}