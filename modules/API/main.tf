locals { 
  domainName = "${lower(var.ENV) == "prod" ? "api.cecurecloud.com" : "api.${lower(var.ENV)}.cecurecloud.com"}"
}

resource "aws_api_gateway_rest_api" "api-gateway" {
  name        = "${var.RESOURCE_PREFIX}"
  description = ""
}

resource "aws_api_gateway_model" "AccountId_Model" {
  rest_api_id  = "${aws_api_gateway_rest_api.api-gateway.id}"
  name         = "UpdateAccount"
  description  = "a JSON schema"
  content_type = "application/json"

  schema = <<EOF
{ "$schema": "http://json-schema.org/draft-04/schema#",
  "title": "Account Id",
  "type": "object",
  "properties": {
      Organization":{ "type": "string" },
      "budgetContact": {
        "type": "string"
      },
      "technicalContact": {
        "type": "string"
      },
      "supportContact": {
        "type": "string"
      }
    }
}
EOF
}



resource "aws_api_gateway_request_validator" "update-account-request-validator" {
  name                        = "update_account"
  rest_api_id                 = "${aws_api_gateway_rest_api.api-gateway.id}"
  validate_request_body       = true
  validate_request_parameters = false
}



resource "aws_api_gateway_deployment" "api-gateway-deployment" {
  depends_on = [
    "aws_api_gateway_method.update_accounts_table_method",
    "aws_api_gateway_integration.update_accounts_table_integration",
    "aws_api_gateway_method.options_root_method",
    "aws_api_gateway_integration.options_root_integration",
    "aws_api_gateway_method.options_accountId_method",
    "aws_api_gateway_integration.options_accountId_integration",
    "aws_api_gateway_method.options_cuid_method",
    "aws_api_gateway_integration.options_cuid_integration",
    "aws_api_gateway_method.get_account_info_method",
    "aws_api_gateway_integration.get_account_info_integration",
    "aws_api_gateway_method.options_accounts_method",
    "aws_api_gateway_integration.options_accounts_integration",
    "aws_api_gateway_method.list_cust_accounts_method",
    "aws_api_gateway_integration.list_cust_accounts_integration",
    
    "aws_api_gateway_gateway_response.custom_gateway_response_cors_4XX",
    "aws_api_gateway_gateway_response.custom_gateway_response_cors_5XX"
  ]
  rest_api_id       = "${aws_api_gateway_rest_api.api-gateway.id}"
  stage_name        = "${lower(var.ENV)}"
  stage_description = "1.0"
  description       = "1.0"
  
  variables = {
    "deployed_at" = "${timestamp()}"
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# api authorizer

resource "aws_api_gateway_authorizer" "api-gateway-authorizer" {
  name                   = "authorizer"
  rest_api_id            = "${aws_api_gateway_rest_api.api-gateway.id}"
  authorizer_uri         = "${var.LAMBDA_AUTHORIZER_INVOKE_ARN}"
  type                   = "REQUEST"
  identity_source        = "method.request.header.Authorization"
  authorizer_result_ttl_in_seconds = "0"
}
resource "aws_api_gateway_resource" "aws_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.api-gateway.root_resource_id}"
  path_part   = "aws"
}
resource "aws_api_gateway_resource" "cuid_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  parent_id   = "${aws_api_gateway_resource.aws_resource.id}" 
  path_part   = "{cuid}"
}

resource "aws_api_gateway_resource" "cuid_accountid_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  parent_id   = "${aws_api_gateway_resource.cuid_accounts_resource.id}"
  path_part   = "{accountId}"
}

resource "aws_api_gateway_resource" "cuid_accounts_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  parent_id   = "${aws_api_gateway_resource.euid_resource.id}"
  path_part   = "accounts"
}

resource "aws_api_gateway_resource" "euid_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  parent_id   = "${aws_api_gateway_resource.cuid_resource.id}"
  path_part   = "{euid}"
}

resource "aws_api_gateway_base_path_mapping" "api-gateway-base-path-mapping" {
  api_id      = "${aws_api_gateway_rest_api.api-gateway.id}"
  stage_name  = "${aws_api_gateway_deployment.api-gateway-deployment.stage_name}"
  domain_name = "${local.domainName}"
  base_path = "actmgmt-aws"
}

### Option Method For Root ###

resource "aws_api_gateway_method" "options_root_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id   = "${aws_api_gateway_rest_api.api-gateway.root_resource_id}"
  http_method   = "OPTIONS"
  
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_root_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id             = "${aws_api_gateway_rest_api.api-gateway.root_resource_id}"
  http_method             = "${aws_api_gateway_method.options_root_method.http_method}"
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

resource "aws_api_gateway_method_response" "options_root_method_response_200" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id = "${aws_api_gateway_rest_api.api-gateway.root_resource_id}"
  http_method = "${aws_api_gateway_method.options_root_method.http_method}"
  status_code = "200"
  response_parameters = "${local.method_response_parameters}"

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    "aws_api_gateway_method.options_root_method",
  ]
}

resource "aws_api_gateway_integration_response" "options_root_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id = "${aws_api_gateway_rest_api.api-gateway.root_resource_id}"
  http_method = "${aws_api_gateway_method_response.options_root_method_response_200.http_method}"
  status_code = "${aws_api_gateway_method_response.options_root_method_response_200.status_code}"

  response_parameters = "${local.integration_response_parameters}"

  depends_on = [
    "aws_api_gateway_integration.options_root_integration",
    "aws_api_gateway_method_response.options_root_method_response_200",
  ]
}

### Option Method For /cuid/accountId ###

resource "aws_api_gateway_method" "options_accountId_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id   = "${aws_api_gateway_resource.cuid_accountid_resource.id}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_accountId_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id             = "${aws_api_gateway_resource.cuid_accountid_resource.id}"
  http_method             = "${aws_api_gateway_method.options_accountId_method.http_method}"
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

resource "aws_api_gateway_method_response" "options_accountId_method_response_200" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id = "${aws_api_gateway_resource.cuid_accountid_resource.id}"
  http_method = "${aws_api_gateway_method.options_accountId_method.http_method}"
  status_code = "200"
  response_parameters = "${local.method_response_parameters}"

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    "aws_api_gateway_method.options_accountId_method",
  ]
}

resource "aws_api_gateway_integration_response" "options_accountId_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id = "${aws_api_gateway_resource.cuid_accountid_resource.id}"
  http_method = "${aws_api_gateway_method_response.options_accountId_method_response_200.http_method}"
  status_code = "${aws_api_gateway_method_response.options_accountId_method_response_200.status_code}"

  response_parameters = "${local.integration_response_parameters}"

  depends_on = [
    "aws_api_gateway_integration.options_accountId_integration",
    "aws_api_gateway_method_response.options_accountId_method_response_200",
  ]
}



### Option Method For /aws ###

resource "aws_api_gateway_method" "options_aws_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id   = "${aws_api_gateway_resource.aws_resource.id}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_aws_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id             = "${aws_api_gateway_resource.aws_resource.id}"
  http_method             = "${aws_api_gateway_method.options_aws_method.http_method}"
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

resource "aws_api_gateway_method_response" "options_aws_method_response_200" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id = "${aws_api_gateway_resource.aws_resource.id}"
  http_method = "${aws_api_gateway_method.options_aws_method.http_method}"
  status_code = "200"
  response_parameters = "${local.method_response_parameters}"

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    "aws_api_gateway_method.options_aws_method",
  ]
}

resource "aws_api_gateway_integration_response" "options_aws_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id = "${aws_api_gateway_resource.aws_resource.id}"
  http_method = "${aws_api_gateway_method_response.options_aws_method_response_200.http_method}"
  status_code = "${aws_api_gateway_method_response.options_aws_method_response_200.status_code}"

  response_parameters = "${local.integration_response_parameters}"

  depends_on = [
    "aws_api_gateway_integration.options_aws_integration",
    "aws_api_gateway_method_response.options_aws_method_response_200",
  ]
}



### Option Method For /cuid ###

resource "aws_api_gateway_method" "options_cuid_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id   = "${aws_api_gateway_resource.cuid_resource.id}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_cuid_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id             = "${aws_api_gateway_resource.cuid_resource.id}"
  http_method             = "${aws_api_gateway_method.options_cuid_method.http_method}"
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

resource "aws_api_gateway_method_response" "options_cuid_method_response_200" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id = "${aws_api_gateway_resource.cuid_resource.id}"
  http_method = "${aws_api_gateway_method.options_cuid_method.http_method}"
  status_code = "200"
  response_parameters = "${local.method_response_parameters}"

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    "aws_api_gateway_method.options_accountId_method",
  ]
}

resource "aws_api_gateway_integration_response" "options_cuid_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id = "${aws_api_gateway_resource.cuid_resource.id}"
  http_method = "${aws_api_gateway_method_response.options_cuid_method_response_200.http_method}"
  status_code = "${aws_api_gateway_method_response.options_cuid_method_response_200.status_code}"

  response_parameters = "${local.integration_response_parameters}"

  depends_on = [
    "aws_api_gateway_integration.options_cuid_integration",
    "aws_api_gateway_method_response.options_cuid_method_response_200",
  ]
}

### Option Method For /euid ###

resource "aws_api_gateway_method" "options_euid_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id   = "${aws_api_gateway_resource.euid_resource.id}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_euid_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id             = "${aws_api_gateway_resource.euid_resource.id}"
  http_method             = "${aws_api_gateway_method.options_euid_method.http_method}"
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

resource "aws_api_gateway_method_response" "options_euid_method_response_200" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id = "${aws_api_gateway_resource.euid_resource.id}"
  http_method = "${aws_api_gateway_method.options_euid_method.http_method}"
  status_code = "200"
  response_parameters = "${local.method_response_parameters}"

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    "aws_api_gateway_method.options_accountId_method",
  ]
}

resource "aws_api_gateway_integration_response" "options_euid_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id = "${aws_api_gateway_resource.euid_resource.id}"
  http_method = "${aws_api_gateway_method_response.options_euid_method_response_200.http_method}"
  status_code = "${aws_api_gateway_method_response.options_euid_method_response_200.status_code}"

  response_parameters = "${local.integration_response_parameters}"

  depends_on = [
    "aws_api_gateway_integration.options_euid_integration",
    "aws_api_gateway_method_response.options_euid_method_response_200",
  ]
}



### Option Method For /cuid/accounts ###

resource "aws_api_gateway_method" "options_accounts_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id   = "${aws_api_gateway_resource.cuid_accounts_resource.id}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_accounts_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id             = "${aws_api_gateway_resource.cuid_accounts_resource.id}"
  http_method             = "${aws_api_gateway_method.options_accounts_method.http_method}"
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

resource "aws_api_gateway_method_response" "options_accounts_method_response_200" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id = "${aws_api_gateway_resource.cuid_accounts_resource.id}"
  http_method = "${aws_api_gateway_method.options_accounts_method.http_method}"
  status_code = "200"
  response_parameters = "${local.method_response_parameters}"

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    "aws_api_gateway_method.options_accounts_method",
  ]
}

resource "aws_api_gateway_integration_response" "options_accounts_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id = "${aws_api_gateway_resource.cuid_accounts_resource.id}"
  http_method = "${aws_api_gateway_method_response.options_accounts_method_response_200.http_method}"
  status_code = "${aws_api_gateway_method_response.options_accounts_method_response_200.status_code}"

  response_parameters = "${local.integration_response_parameters}"

  depends_on = [
    "aws_api_gateway_integration.options_accounts_integration",
    "aws_api_gateway_method_response.options_accounts_method_response_200",
  ]
}

## Update Accounts Table Method ###

resource "aws_api_gateway_method" "update_accounts_table_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id   = "${aws_api_gateway_resource.cuid_accountid_resource.id}"
  http_method   = "POST"
  
  authorization = "CUSTOM"
  authorizer_id = "${aws_api_gateway_authorizer.api-gateway-authorizer.id}"
  depends_on = [
    "aws_api_gateway_authorizer.api-gateway-authorizer"
  ]
    request_models = {
    "application/json" : "${aws_api_gateway_model.AccountId_Model.name}"
  }
  
  request_validator_id = "${aws_api_gateway_request_validator.update-account-request-validator.id}"

}

resource "aws_api_gateway_integration" "update_accounts_table_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id             = "${aws_api_gateway_resource.cuid_accountid_resource.id}"
  http_method             = "${aws_api_gateway_method.update_accounts_table_method.http_method}"
  type                    = "AWS"
  uri                     = "${var.LAMBDA_UPDATE_ACCOUNTS_TABLE_INVOKE_ARN}"
  integration_http_method = "POST"
  request_templates = {
    "application/json" = <<EOF
#set($user_auth_json_body = $util.parseJson($context.authorizer.user))
#set($inputRoot = $input.path('$')) {
#foreach($key in $inputRoot.keySet())
    "$key": "$util.escapeJavaScript($inputRoot.get($key))",
#end
    "cuid": "$input.params('cuid')",
    "accountId": "$input.params('accountId')",
    "user_info_auth_01_email": "$user_auth_json_body.email",
    "user_info_auth_01_euid": "$user_auth_json_body.get('custom:euid')"
}
  EOF
  }


}

resource "aws_api_gateway_method_response" "update_accounts_table_method_response_200" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id = "${aws_api_gateway_resource.cuid_accountid_resource.id}"
  http_method = "${aws_api_gateway_method.update_accounts_table_method.http_method}"
  status_code = "200"
  response_parameters = "${local.method_response_parameters}"
}

resource "aws_lambda_permission" "update_accounts_table_permission" {
  function_name = "${var.LAMBDA_UPDATE_ACCOUNTS_TABLE_NAME}"
  statement_id  = "update-accounts-table"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*"
}

resource "aws_api_gateway_integration_response" "update_accounts_table_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id = "${aws_api_gateway_resource.cuid_accountid_resource.id}"
  http_method = "${aws_api_gateway_method_response.update_accounts_table_method_response_200.http_method}"
  status_code = "${aws_api_gateway_method_response.update_accounts_table_method_response_200.status_code}"

  response_parameters = "${local.integration_response_parameters}"

  response_templates = {
    "application/json" = ""
  }

  depends_on = ["aws_api_gateway_integration.update_accounts_table_integration"]
}

### Get Account Information Method ###

resource "aws_api_gateway_method" "get_account_info_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id   = "${aws_api_gateway_resource.cuid_accountid_resource.id}"
  http_method   = "GET"
  
  authorization = "CUSTOM"
  authorizer_id = "${aws_api_gateway_authorizer.api-gateway-authorizer.id}"
  depends_on = [
    "aws_api_gateway_authorizer.api-gateway-authorizer"
  ]

}

resource "aws_api_gateway_integration" "get_account_info_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id             = "${aws_api_gateway_resource.cuid_accountid_resource.id}"
  http_method             = "${aws_api_gateway_method.get_account_info_method.http_method}"
  type                    = "AWS"
  uri                     = "${var.LAMBDA_GET_ACCOUNT_INFO_INVOKE_ARN}"
  integration_http_method = "POST"
  request_templates = {
    "application/json" = <<EOF
{
"cuid": "$input.params('cuid')",
"accountId": "$input.params('accountId')"
}
  EOF
  }


}

resource "aws_api_gateway_method_response" "get_account_info_method_response_200" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id = "${aws_api_gateway_resource.cuid_accountid_resource.id}"
  http_method = "${aws_api_gateway_method.get_account_info_method.http_method}"
  status_code = "200"
  response_parameters = "${local.method_response_parameters}"
}

resource "aws_lambda_permission" "get_account_info_permission" {
  function_name = "${var.LAMBDA_GET_ACCOUNT_INFO_NAME}"
  statement_id  = "get-account-info"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*"
}

resource "aws_api_gateway_integration_response" "get_account_info_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id = "${aws_api_gateway_resource.cuid_accountid_resource.id}"
  http_method = "${aws_api_gateway_method_response.get_account_info_method_response_200.http_method}"
  status_code = "${aws_api_gateway_method_response.get_account_info_method_response_200.status_code}"

  response_parameters = "${local.integration_response_parameters}"

  response_templates = {  
    "application/json" = ""
  }

  depends_on = ["aws_api_gateway_integration.get_account_info_integration"]
}

### Get Customer Accounts Method ###

resource "aws_api_gateway_method" "list_cust_accounts_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id   = "${aws_api_gateway_resource.cuid_accounts_resource.id}"
  http_method   = "GET"
  
  authorization = "CUSTOM"
  authorizer_id = "${aws_api_gateway_authorizer.api-gateway-authorizer.id}"
  depends_on = [
    "aws_api_gateway_authorizer.api-gateway-authorizer"
  ]
  
  # request_validator_id = "${aws_api_gateway_request_validator.list-account-details-request-validator.id}"
  # authorization = "NONE"
}

resource "aws_api_gateway_integration" "list_cust_accounts_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id             = "${aws_api_gateway_resource.cuid_accounts_resource.id}"
  http_method             = "${aws_api_gateway_method.list_cust_accounts_method.http_method}"
  type                    = "AWS"
  uri                     = "${var.LAMBDA_LIST_CUST_ACCOUNTS_INVOKE_ARN}"
  integration_http_method = "POST"
  request_templates = {
    "application/json" = <<EOF
{
"cuid": "$input.params('cuid')",
"euid": "$input.params('euid')"
}
  EOF
  }
}

resource "aws_api_gateway_method_response" "list_cust_accounts_method_response_200" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id = "${aws_api_gateway_resource.cuid_accounts_resource.id}"
  http_method = "${aws_api_gateway_method.list_cust_accounts_method.http_method}"
  status_code = "200"
  response_parameters = "${local.method_response_parameters}"
}

resource "aws_lambda_permission" "list_cust_accounts_permission" {
  function_name = "${var.LAMBDA_LIST_CUST_ACCOUNTS_NAME}"
  statement_id  = "list-cust-accounts"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*"
}

resource "aws_api_gateway_integration_response" "list_cust_accounts_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id = "${aws_api_gateway_resource.cuid_accounts_resource.id}"
  http_method = "${aws_api_gateway_method_response.list_cust_accounts_method_response_200.http_method}"
  status_code = "${aws_api_gateway_method_response.list_cust_accounts_method_response_200.status_code}"

  response_parameters = "${local.integration_response_parameters}"

  response_templates = {  
    "application/json" = ""
  }

  depends_on = ["aws_api_gateway_integration.list_cust_accounts_integration"]
}



# API Gateway Custom Responses
# ****************************

resource "aws_api_gateway_gateway_response" "custom_gateway_response_cors_4XX" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  response_type = "DEFAULT_4XX"

  response_templates = {
    "application/json" = "{'message':$context.error.messageString}"
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin" = "'${var.allow_origin}'"
    "gatewayresponse.header.Strict-Transport-Security" = "'${var.Strict_Transport_Security}'"
    "gatewayresponse.header.referrer-policy" = "'${var.Referrer_Policy}'"
    "gatewayresponse.header.x-xss-protection" = "'${var.X_XSS_Protection}'"
    "gatewayresponse.header.x-frame-options" = "'${var.X_Frame_Options}'"
    "gatewayresponse.header.x-content-type-options" = "'${var.X_Content_Type_Options}'"
    "gatewayresponse.header.content-security-policy" = "'${var.Content_Security_Policy}'"
  }
} 

resource "aws_api_gateway_gateway_response" "custom_gateway_response_BAD_REQUEST_BODY" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  response_type = "BAD_REQUEST_BODY"

  response_templates = {
    "application/json" = "{\"message\":\"$context.error.validationErrorString\"}"
  }


  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin" = "'${var.allow_origin}'"
    "gatewayresponse.header.Strict-Transport-Security" = "'${var.Strict_Transport_Security}'"
    "gatewayresponse.header.referrer-policy" = "'${var.Referrer_Policy}'"
    "gatewayresponse.header.x-xss-protection" = "'${var.X_XSS_Protection}'"
    "gatewayresponse.header.x-frame-options" = "'${var.X_Frame_Options}'"
    "gatewayresponse.header.x-content-type-options" = "'${var.X_Content_Type_Options}'"
    "gatewayresponse.header.content-security-policy" = "'${var.Content_Security_Policy}'"
  }
} 



resource "aws_api_gateway_gateway_response" "custom_gateway_response_cors_5XX" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  response_type = "DEFAULT_5XX"

  response_templates = {
    "application/json" = "{'message':$context.error.messageString}"
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin" = "'${var.allow_origin}'"
    "gatewayresponse.header.Strict-Transport-Security" = "'${var.Strict_Transport_Security}'"
    "gatewayresponse.header.referrer-policy" = "'${var.Referrer_Policy}'"
    "gatewayresponse.header.x-xss-protection" = "'${var.X_XSS_Protection}'"
    "gatewayresponse.header.x-frame-options" = "'${var.X_Frame_Options}'"
    "gatewayresponse.header.x-content-type-options" = "'${var.X_Content_Type_Options}'"
    "gatewayresponse.header.content-security-policy" = "'${var.Content_Security_Policy}'"
  }
}