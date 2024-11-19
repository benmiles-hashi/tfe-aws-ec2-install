resource "aws_s3_bucket" "tfe_ec2_s3" {
  bucket = var.s3_bucket
  tags = {
    Name        = "TFE EC2 Bucket"
  }
}
resource "aws_s3_bucket_policy" "allow_access_role" {
  bucket = aws_s3_bucket.tfe_ec2_s3.id
  policy = data.aws_iam_policy_document.allow_access_role.json
}

data "aws_iam_policy_document" "allow_access_role" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::211125709634:role/s3-ecs-access-role"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:PutObjectAcl"
    ]

    resources = [
      aws_s3_bucket.tfe_ec2_s3.arn,
      "${aws_s3_bucket.tfe_ec2_s3.arn}/*",
    ]
  }
}