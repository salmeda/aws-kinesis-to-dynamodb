data "archive_file" "python_lambda_package" {  
  type = "zip"  
  source_file = "code/lambda_function.py" 
  output_path = "lambda_function.zip"
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

resource "aws_iam_role" "kinesis-to-ddb-lbd-role" {
  name               = "kinesis-to-ddb-lbd-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
            solution    = "kinesis_to_dynamodb"
            environment = "dev"
          }
}

resource "aws_iam_policy" "LambdaBasicExecutionRole-kds-to-ddb-policy" {
  name        = "LambdaBasicExecutionRole-kds-to-ddb-policy"
  path        = "/"
  description = "Policy for Lambda to access Cloud Logs, etc"

  tags = {
            solution    = "kinesis_to_dynamodb"
            environment = "dev"
          }
# Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:eu-west-2:178795408598:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:CreateLogGroup", 
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:eu-west-2:178795408598:log-group:/aws/lambda/kinesis-to-ddb-lambda:*"
            ]
        }
    ]
})
}


resource "aws_iam_policy" "kinesis-to-ddb-policy" {
  name        = "kinesis-to-ddb-policy"
  path        = "/"
  description = "Policy for Lambda to access Kinesis"

  tags = {
            solution    = "kinesis_to_dynamodb"
            environment = "dev"
          }

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"kinesis:DescribeStream",
				"kinesis:DescribeStreamSummary",
				"kinesis:GetRecords",
				"kinesis:GetShardIterator",
				"kinesis:ListShards",
				"kinesis:ListStreams",
				"kinesis:SubscribeToShard",
				"logs:CreateLogGroup",
				"logs:CreateLogStream",
				"logs:PutLogEvents"
			],
			"Resource": "arn:aws:kinesis:eu-west-2:178795408598:stream/kinesis-to-dynamodb-kds"
		}
	]
})
}

resource "aws_iam_policy" "kinesis-to-ddb-ddb-policy" {
  name        = "kinesis-to-ddb-ddb-policy"
  path        = "/"
  description = "Policy for Lambda to access ddb"

  tags = {
            solution    = "kinesis_to_dynamodb"
            environment = "dev"
          }

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:DescribeStream",
                "dynamodb:GetRecords",
                "dynamodb:PutItem",
                "dynamodb:GetShardIterator",
                "dynamodb:ListStreams",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:dynamodb:eu-west-2:178795408598:*table/kinesis-to-dynamodb-ddb"
        }
    ]
})
}




resource "aws_iam_policy_attachment" "kinesis-to-ddb-lbd-attch1" {
  name       = "kinesis-to-ddb-lbd-attch1" 
  roles      = [aws_iam_role.kinesis-to-ddb-lbd-role.name]
  policy_arn = aws_iam_policy.LambdaBasicExecutionRole-kds-to-ddb-policy.arn
}


resource "aws_iam_policy_attachment" "kinesis-to-ddb-lbd-attch2" {
  name       = "kinesis-to-ddb-lbd-attch2" 
  roles      = [aws_iam_role.kinesis-to-ddb-lbd-role.name]
  policy_arn = aws_iam_policy.kinesis-to-ddb-policy.arn
 
}

resource "aws_iam_policy_attachment" "kinesis-to-ddb-lbd-attch3" {
  name       = "kinesis-to-ddb-lbd-attch3" 
  roles      = [aws_iam_role.kinesis-to-ddb-lbd-role.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
 
}

resource "aws_iam_policy_attachment" "kinesis-to-ddb-lbd-attch4" {
  name       = "kinesis-to-ddb-lbd-attch4" 
  roles      = [aws_iam_role.kinesis-to-ddb-lbd-role.name]
  policy_arn = aws_iam_policy.kinesis-to-ddb-ddb-policy.arn
 
}

resource "aws_lambda_function" "kinesis-to-ddb-lbd" {
        function_name = "kinesis-to-ddb-lbd"
        filename      = "lambda_function.zip"
        source_code_hash = data.archive_file.python_lambda_package.output_base64sha256
        role          = aws_iam_role.kinesis-to-ddb-lbd-role.arn
        runtime       = "python3.10"
        handler       = "lambda_function.lambda_handler"
        timeout       = 10

        tags = {
            solution    = "kinesis_to_dynamodb"
            environment = "dev"
          }
}

resource "aws_lambda_event_source_mapping" "kinesis-to-ddb-lbd-erm" {
  event_source_arn  = aws_kinesis_stream.kinesis-to-dynamodb-kds.arn
  function_name     = aws_lambda_function.kinesis-to-ddb-lbd.arn
  starting_position = "TRIM_HORIZON"

  depends_on = [
    aws_iam_policy_attachment.kinesis-to-ddb-lbd-attch2
  ]
}

