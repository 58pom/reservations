# CloudFront 経由で配信する S3 バケット
resource "aws_s3_bucket" "main" {
  bucket = "kbysmsak.com"
}

# S3バケット内にフォルダの作成
resource "aws_s3_object" "scripts" {
  bucket = "${aws_s3_bucket.main.id}"
  key = "scripts/"
}
resource "aws_s3_object" "styles" {
  bucket = aws_s3_bucket.main.id
  key = "styles/"
}


resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# バケットポリシー
resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.s3_main_policy.json
}

data "aws_iam_policy_document" "s3_main_policy" {
  # CloudFront Distribution からのアクセスのみ許可
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.main.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.main.arn]
    }
  }
}

# ローカルファイルと対応するContent-Typeを定義
locals {
  files = [
    { path = "index.html", type = "text/html" },
    { path = "config.js", type = "text/javascript" },
    { path = "scripts/scripts.js", type = "text/javascript" },
    { path = "styles/styles.css", type = "text/css" }
  ]
}

# 複数ファイルをS3にアップロード
resource "aws_s3_object" "upload_files" {
  for_each = { for file in local.files : file.path => file }

  bucket       = aws_s3_bucket.main.id
  key          = each.value.path # ファイル名のみをキーとして使用
  source       = "src/${each.value.path}"  # ローカルファイルパス
  acl          = "private"                 # 必要に応じて変更
  content_type = each.value.type           # Content-Typeを指定
  etag         = filemd5("src/${each.value.path}")
}
