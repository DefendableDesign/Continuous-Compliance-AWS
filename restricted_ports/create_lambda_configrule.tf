resource "aws_iam_role" "r_configrule" {
    name = "DD-AWSConfig-EC2ExposedPorts-Role"

    assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "p_configrule" {
    name = "DD-AWSConfig-EC2ExposedPorts-Policy"
    role = "${aws_iam_role.r_configrule.id}"
    
    policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sqs:SendMessage"
            ],
            "Effect": "Allow",
            "Resource": "${aws_sqs_queue.q.arn}"
        },
        {
            "Action": [
                "config:PutEvaluations"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        }
    ]
}
POLICY
}

resource "aws_lambda_function" "lf_configrule" {
    filename         = "${data.archive_file.lambda_configrule.output_path}"
    function_name    = "DD_AWSConfig_EC2ExposedPorts_ConfigRule"
    role             = "${aws_iam_role.r_configrule.arn}"
    handler          = "DD-AWSConfig-EC2ExposedPorts.lambda_handler"
    source_code_hash = "${base64sha256(file("${data.archive_file.lambda_configrule.output_path}"))}"
    runtime          = "python2.7"
    timeout          = "10"
}

resource "aws_lambda_permission" "with_config" {
    statement_id  = "DD-AWSConfig-EC2ExposedPorts-LambdaPermission"
    action        = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.lf_configrule.function_name}"
    principal     = "config.amazonaws.com"
}
