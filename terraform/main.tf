 terraform {
   required_version = ">= 1.8.0"
   required_providers {
     aws = {
       source  = "hashicorp/aws"
       version = ">= 5.0.0"
     }
   }
 }

 provider "aws" {
   region = "eu-west-2"
 }

 resource "aws_dynamodb_table" "kinesis-to-dynamodb-ddb" {
  name           = "kinesis-to-dynamodb-ddb"
  billing_mode   = "PAY_PER_REQUEST" 
  hash_key       = "sensorId"
  range_key      = "s_timestamp"

  attribute {
    name = "sensorId"
    type = "N"
  }

  attribute {
    name = "s_timestamp"
    type = "S"
  }
  

   tags = {
    solution    = "kinesis_to_dynamodb"
    environment = "dev"
  }
 
}

resource "aws_kinesis_stream" "kinesis-to-dynamodb-kds" {
  name             = "kinesis-to-dynamodb-kds" 
  retention_period = 24
 

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

   tags = {
    solution    = "kinesis_to_dynamodb"
    environment = "dev"
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "test-iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
 

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function_payload.json"
  function_name = "salmeda-lambda_function"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.test"
 
  runtime = "python3.10"

  environment {
    variables = {
      foo = "bar"
    }
  }
}