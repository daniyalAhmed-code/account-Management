resource "aws_lambda_layer_version" "share_python_lib" {
  layer_name = "${var.RESOURCE_PREFIX}-shared-lib-python"
  filename   = "${path.module}/layers/shared_lib.zip"
  source_code_hash = "${filebase64sha256("${path.module}/layers/shared_lib.zip")}"
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