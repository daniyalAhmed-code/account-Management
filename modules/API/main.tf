resource "aws_api_gateway_rest_api" "api-gateway-platform-api" {
  name        = "${var.RESOURCE_PREFIX}-platform-api"
  description = "Platform API to trigger lambda function."
  # policy = "${data.template_file.api-gateway-policy.rendered}"
  tags = {"Name":"TEST_API"}
}
# resource "aws_api_gateway_base_path_mapping" "api-gateway-base-path-mapping-platform-api-aws" {
#   api_id      = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
#    stage_name  = "dis"
#    domain_name = "api3.eurustechnologies.info"
#   base_path = "public-actmgmt"
# }



# API Gateway Custom Responses
# ****************************

resource "aws_api_gateway_gateway_response" "custom_gateway_response_cors_4XX_platform_api" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
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

resource "aws_api_gateway_gateway_response" "custom_gateway_response_cors_5XX_platform_api" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
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
# api authorizer
resource "aws_api_gateway_authorizer" "api-gateway-authorizer-platform-api" {
  name                   = "${var.RESOURCE_PREFIX}-api-authorizer"
  rest_api_id            = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  authorizer_uri         = "${var.LAMBDA_AUTHORIZER_INVOKE_ARN}"
  authorizer_credentials = "${var.LAMBDA_ROLE_ARN}"
  type                   = "REQUEST"
  identity_source        = "method.request.header.Authorization"
  authorizer_result_ttl_in_seconds = "0"
}

#####------#####
#----Resource Methods on Root
#####------#####

#### Resource OPTIONS method ####
module "Resource_resource_option_platform_api" {
  source = "./modules/ApiMethods"
  METHOD_VALUE = ""
  API_GATEWAY_ID = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  RESOURCE_ID = "${aws_api_gateway_rest_api.api-gateway-platform-api.root_resource_id}"
  INTEGRATION_RESPONSE_PARAMETERS = "${local.integration_response_parameters}"
  METHOD_RESPONSE_PARAMETERS = "${local.method_response_parameters}"
  HTTP_METHOD = "OPTIONS"
  AUTHORIZATION = "NONE"
}



####----------####
####  AWS 
####----------####

resource "aws_api_gateway_resource" "aws_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api-gateway-platform-api.root_resource_id}"
  path_part   = "aws"
}
resource "aws_api_gateway_resource" "cuid_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  parent_id   = "${aws_api_gateway_resource.aws_resource.id}" 
  path_part   = "{cuid}"
}

resource "aws_api_gateway_resource" "cuid_accountid_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  parent_id   = "${aws_api_gateway_resource.cuid_accounts_resource.id}"
  path_part   = "{accountId}"
}

resource "aws_api_gateway_resource" "cuid_accounts_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  parent_id   = "${aws_api_gateway_resource.euid_resource.id}"
  path_part   = "accounts"
}

resource "aws_api_gateway_resource" "euid_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  parent_id   = "${aws_api_gateway_resource.cuid_resource.id}"
  path_part   = "{euid}"
}




#### AWS OPTIONS method ####
module "aws_resource_option_platform_api" {
  source = "./modules/ApiMethods"
  METHOD_VALUE = ""
  API_GATEWAY_ID = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  RESOURCE_ID = "${aws_api_gateway_resource.aws_resource.id}"
  INTEGRATION_RESPONSE_PARAMETERS = "${local.integration_response_parameters}"
  METHOD_RESPONSE_PARAMETERS = "${local.method_response_parameters}"
  HTTP_METHOD = "OPTIONS"
  AUTHORIZATION = "NONE"
}
//
module "aws_cuid_resource_option_platform_api" {
  source = "./modules/ApiMethods"
  METHOD_VALUE = ""
  API_GATEWAY_ID = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  RESOURCE_ID = "${aws_api_gateway_resource.cuid_resource.id}"
  INTEGRATION_RESPONSE_PARAMETERS = "${local.integration_response_parameters}"
  METHOD_RESPONSE_PARAMETERS = "${local.method_response_parameters}"
  HTTP_METHOD = "OPTIONS"
  AUTHORIZATION = "NONE"
}
//
module "aws_cuid_accountid_resource_option_platform_api" {
  source = "./modules/ApiMethods"
  METHOD_VALUE = ""
  API_GATEWAY_ID = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  RESOURCE_ID = "${aws_api_gateway_resource.cuid_accountid_resource.id}"
  INTEGRATION_RESPONSE_PARAMETERS = "${local.integration_response_parameters}"
  METHOD_RESPONSE_PARAMETERS = "${local.method_response_parameters}"
  HTTP_METHOD = "OPTIONS"
  AUTHORIZATION = "NONE"
}
//
module "aws_cuid_accounts_resource_option_platform_api" {
  source = "./modules/ApiMethods"
  METHOD_VALUE = ""
  API_GATEWAY_ID = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  RESOURCE_ID = "${aws_api_gateway_resource.cuid_accounts_resource.id}"
  INTEGRATION_RESPONSE_PARAMETERS = "${local.integration_response_parameters}"
  METHOD_RESPONSE_PARAMETERS = "${local.method_response_parameters}"
  HTTP_METHOD = "OPTIONS"
  AUTHORIZATION = "NONE"
}
//
module "aws_euid_resource_option_platform_api" {
  source = "./modules/ApiMethods"
  METHOD_VALUE = ""
  API_GATEWAY_ID = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  RESOURCE_ID = "${aws_api_gateway_resource.euid_resource.id}"
  INTEGRATION_RESPONSE_PARAMETERS = "${local.integration_response_parameters}"
  METHOD_RESPONSE_PARAMETERS = "${local.method_response_parameters}"
  HTTP_METHOD = "OPTIONS"
  AUTHORIZATION = "NONE"
}


#### AWS GET method ####
module "aws_resource_LIST_api" {
  source = "./modules/ApiMethods"
  METHOD_VALUE = ""
  API_GATEWAY_ID = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  RESOURCE_ID = "${aws_api_gateway_resource.cuid_accounts_resource.id}"
  INTEGRATION_RESPONSE_PARAMETERS = "${local.integration_response_parameters}"
  METHOD_RESPONSE_PARAMETERS = "${local.method_response_parameters}"
  AUTHORIZATION = "CUSTOM"
  AUTHORIZER_ID = "${aws_api_gateway_authorizer.api-gateway-authorizer-platform-api.id}"

  HTTP_METHOD = "GET"
  LAMBDA_INVOKE_ARN = "${var.AWS_LAMBDA_LIST_CUST_ACCOUNTS_INVOKE_ARN}"
  FUNCTION_NAME = "${var.AWS_LAMBDA_LIST_CUST_ACCOUNTS_NAME}"
  SOURCE_ARN = "${aws_api_gateway_rest_api.api-gateway-platform-api.execution_arn}/*/GET/list"
  REQUEST_TEMPLATES = {
  "application/json" = <<EOF
 {
"cuid": "$input.params('cuid')",
"accountId": "$input.params('accountId')"
}
    EOF
    }
}

module "aws_resource_POST_api" {
  source = "./modules/ApiMethods"
  METHOD_VALUE = ""
  API_GATEWAY_ID = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  RESOURCE_ID = "${aws_api_gateway_resource.cuid_accountid_resource.id}"
  INTEGRATION_RESPONSE_PARAMETERS = "${local.integration_response_parameters}"
  METHOD_RESPONSE_PARAMETERS = "${local.method_response_parameters}"
  AUTHORIZATION = "CUSTOM"
  AUTHORIZER_ID = "${aws_api_gateway_authorizer.api-gateway-authorizer-platform-api.id}"

  HTTP_METHOD = "POST"
  LAMBDA_INVOKE_ARN = "${var.AWS_LAMBDA_UPDATE_ACCOUNTS_TABLE_INVOKE_ARN}"
  FUNCTION_NAME = "${var.AWS_LAMBDA_UPDATE_ACCOUNTS_TABLE_NAME}"
  SOURCE_ARN = "${aws_api_gateway_rest_api.api-gateway-platform-api.execution_arn}/*/*"
  REQUEST_TEMPLATES = {
  "application/json" = <<EOF
  {
        "cuid": "$input.params('cuid')",
        "euid": "$input.params('euid')"
  }
    EOF
    }
}

module "aws_resource_GET_api" {
  source = "./modules/ApiMethods"
  METHOD_VALUE = ""
  API_GATEWAY_ID = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  RESOURCE_ID = "${aws_api_gateway_resource.cuid_accountid_resource.id}"
  INTEGRATION_RESPONSE_PARAMETERS = "${local.integration_response_parameters}"
  METHOD_RESPONSE_PARAMETERS = "${local.method_response_parameters}"
  AUTHORIZATION = "CUSTOM"
  AUTHORIZER_ID = "${aws_api_gateway_authorizer.api-gateway-authorizer-platform-api.id}"

  HTTP_METHOD = "GET"
  LAMBDA_INVOKE_ARN = "${var.AWS_LAMBDA_GET_ACCOUNT_INFO_INVOKE_ARN}"
  FUNCTION_NAME = "${var.AWS_LAMBDA_GET_ACCOUNT_INFO_NAME}"
  SOURCE_ARN = "${aws_api_gateway_rest_api.api-gateway-platform-api.execution_arn}/*/*"
  REQUEST_TEMPLATES = {
  "application/json" = <<EOF
  {
        "cuid": "$input.params('cuid')",
        "euid": "$input.params('euid')"
  }
    EOF
    }
}

### END OF AWS RESOURCE ###




## GCP RESOURCE START ###



resource "aws_api_gateway_resource" "gcp_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api-gateway-platform-api.root_resource_id}"
  path_part   = "gcp"
}
resource "aws_api_gateway_resource" "gcp_cuid_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  parent_id   = "${aws_api_gateway_resource.gcp_resource.id}" 
  path_part   = "{cuid}"
}

resource "aws_api_gateway_resource" "gcp_cuid_projectid_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  parent_id   = "${aws_api_gateway_resource.cuid_projects_resource.id}"
  path_part   = "{projectId}"
}

resource "aws_api_gateway_resource" "cuid_projects_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  parent_id   = "${aws_api_gateway_resource.gcp_euid_resource.id}"
  path_part   = "projects"
}

resource "aws_api_gateway_resource" "gcp_euid_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  parent_id   = "${aws_api_gateway_resource.gcp_cuid_resource.id}"
  path_part   = "{euid}"
}




#### GCP OPTIONS method ####
module "gcp_projects_resource_option_platform_api" {
  source = "./modules/ApiMethods"
  METHOD_VALUE = ""
  API_GATEWAY_ID = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  RESOURCE_ID = "${aws_api_gateway_resource.cuid_projects_resource.id}"
  INTEGRATION_RESPONSE_PARAMETERS = "${local.integration_response_parameters}"
  METHOD_RESPONSE_PARAMETERS = "${local.method_response_parameters}"
  HTTP_METHOD = "OPTIONS"
  AUTHORIZATION = "NONE"
}
//
module "gcp_projectid_resource_option_platform_api" {
  source = "./modules/ApiMethods"
  METHOD_VALUE = ""
  API_GATEWAY_ID = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  RESOURCE_ID = "${aws_api_gateway_resource.gcp_cuid_projectid_resource.id}"
  INTEGRATION_RESPONSE_PARAMETERS = "${local.integration_response_parameters}"
  METHOD_RESPONSE_PARAMETERS = "${local.method_response_parameters}"
  HTTP_METHOD = "OPTIONS"
  AUTHORIZATION = "NONE"
}
//
module "gcp_euid_resource_option_platform_api" {
  source = "./modules/ApiMethods"
  METHOD_VALUE = ""
  API_GATEWAY_ID = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  RESOURCE_ID = "${aws_api_gateway_resource.gcp_euid_resource.id}"
  INTEGRATION_RESPONSE_PARAMETERS = "${local.integration_response_parameters}"
  METHOD_RESPONSE_PARAMETERS = "${local.method_response_parameters}"
  HTTP_METHOD = "OPTIONS"
  AUTHORIZATION = "NONE"
}
//
module "gcp_cuid_resource_option_platform_api" {
  source = "./modules/ApiMethods"
  METHOD_VALUE = ""
  API_GATEWAY_ID = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  RESOURCE_ID = "${aws_api_gateway_resource.gcp_cuid_resource.id}"
  INTEGRATION_RESPONSE_PARAMETERS = "${local.integration_response_parameters}"
  METHOD_RESPONSE_PARAMETERS = "${local.method_response_parameters}"
  HTTP_METHOD = "OPTIONS"
  AUTHORIZATION = "NONE"
}
module "gcp_resource_option_platform_api" {
  source = "./modules/ApiMethods"
  METHOD_VALUE = ""
  API_GATEWAY_ID = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  RESOURCE_ID = "${aws_api_gateway_resource.gcp_resource.id}"
  INTEGRATION_RESPONSE_PARAMETERS = "${local.integration_response_parameters}"
  METHOD_RESPONSE_PARAMETERS = "${local.method_response_parameters}"
  HTTP_METHOD = "OPTIONS"
  AUTHORIZATION = "NONE"
}


#### GCP GET method ####
module "gcp_resource_LIST_api" {
  source = "./modules/ApiMethods"
  METHOD_VALUE = ""
  API_GATEWAY_ID = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  RESOURCE_ID = "${aws_api_gateway_resource.cuid_projects_resource.id}"
  INTEGRATION_RESPONSE_PARAMETERS = "${local.integration_response_parameters}"
  METHOD_RESPONSE_PARAMETERS = "${local.method_response_parameters}"
  AUTHORIZATION = "CUSTOM"
  AUTHORIZER_ID = "${aws_api_gateway_authorizer.api-gateway-authorizer-platform-api.id}"

  HTTP_METHOD = "GET"
  LAMBDA_INVOKE_ARN = "${var.GCP_LAMBDA_LIST_CUST_ACCOUNTS_INVOKE_ARN}"
  FUNCTION_NAME = "${var.GCP_LAMBDA_LIST_CUST_ACCOUNTS_NAME}"
  SOURCE_ARN = "${aws_api_gateway_rest_api.api-gateway-platform-api.execution_arn}/*/*"
  REQUEST_TEMPLATES = {
  "application/json" = <<EOF
  {
        "cuid": "$input.params('cuid')",
        "euid": "$input.params('euid')"
  }
    EOF
    }
}

module "gcp_resource_POST_api" {
  source = "./modules/ApiMethods"
  METHOD_VALUE = ""
  API_GATEWAY_ID = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  RESOURCE_ID = "${aws_api_gateway_resource.gcp_cuid_projectid_resource.id}"
  INTEGRATION_RESPONSE_PARAMETERS = "${local.integration_response_parameters}"
  METHOD_RESPONSE_PARAMETERS = "${local.method_response_parameters}"
  AUTHORIZATION = "CUSTOM"
  AUTHORIZER_ID = "${aws_api_gateway_authorizer.api-gateway-authorizer-platform-api.id}"

  HTTP_METHOD = "POST"
  LAMBDA_INVOKE_ARN = "${var.GCP_LAMBDA_UPDATE_ACCOUNTS_TABLE_INVOKE_ARN}"
  FUNCTION_NAME = "${var.GCP_LAMBDA_UPDATE_ACCOUNTS_TABLE_NAME}"
  SOURCE_ARN = "${aws_api_gateway_rest_api.api-gateway-platform-api.execution_arn}/*/*"
  REQUEST_TEMPLATES = {
  "application/json" = <<EOF
  {
"cuid": "$input.params('cuid')",
"projectId": "$input.params('projectId')"
}
    EOF
    }
}

module "gcp_resource_GET_api" {
  source = "./modules/ApiMethods"
  METHOD_VALUE = ""
  API_GATEWAY_ID = "${aws_api_gateway_rest_api.api-gateway-platform-api.id}"
  RESOURCE_ID = "${aws_api_gateway_resource.gcp_cuid_projectid_resource.id}"
  INTEGRATION_RESPONSE_PARAMETERS = "${local.integration_response_parameters}"
  METHOD_RESPONSE_PARAMETERS = "${local.method_response_parameters}"
  AUTHORIZATION = "CUSTOM"
  AUTHORIZER_ID = "${aws_api_gateway_authorizer.api-gateway-authorizer-platform-api.id}"

  HTTP_METHOD = "GET"
  LAMBDA_INVOKE_ARN = "${var.GCP_LAMBDA_GET_ACCOUNT_INFO_INVOKE_ARN}"
  FUNCTION_NAME = "${var.GCP_LAMBDA_GET_ACCOUNT_INFO_NAME}"
  SOURCE_ARN = "${aws_api_gateway_rest_api.api-gateway-platform-api.execution_arn}/*/*"
  REQUEST_TEMPLATES = {
  "application/json" = <<EOF
   {
"cuid": "$input.params('cuid')",
"projectId": "$input.params('projectId')"
}
    EOF
    }
}




### END OF GCP RESOURCE ###


