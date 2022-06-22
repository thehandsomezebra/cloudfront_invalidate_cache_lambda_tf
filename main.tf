terraform {
  required_version = ">= 1.0.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.74.1"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_cloudfront_distribution" "your_cloudfront" {
# ... Fill this out 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution
}


data "aws_lambda_function" "invalidate_cache" {
  function_name = "lambda-cloudfront-invalidation"
}

resource "aws_lambda_invocation" "invoke_lambda" {
  function_name = data.aws_lambda_function.invalidate_cache.function_name
  triggers = {
    always_run = "${timestamp()}"
  }
  input = jsonencode({
    "DISTRIBUTION_ID" = "${aws_cloudfront_distribution.your_cloudfront.id}"
  })
}

output "result_entry" {
  value = jsondecode(aws_lambda_invocation.invoke_lambda.result)
}