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

resource "aws_sns_topic" "kinesis-to-dynamodb-sns" {
  name = "kinesis-to-dynamodb-sns"
}