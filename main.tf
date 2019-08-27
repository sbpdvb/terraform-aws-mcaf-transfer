resource "aws_iam_role" "default" {
  name               = var.name
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "transfer.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "default" {
  name   = "${var.name}-DefaultPolicy"
  role   = aws_iam_role.default.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowFullAccesstoS3",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_transfer_server" "default" {
  identity_provider_type = "SERVICE_MANAGED"
  logging_role           = aws_iam_role.default.arn
  tags                   = var.tags
}

resource "aws_transfer_user" "default" {
  server_id      = aws_transfer_server.default.id
  user_name      = var.name
  role           = aws_iam_role.default.arn
  home_directory = ! var.home_directory
}

resource "aws_transfer_ssh_key" "default" {
  server_id = aws_transfer_server.default.id
  user_name = aws_transfer_user.default.user_name
  body      = var.ssh_pub_key
}
