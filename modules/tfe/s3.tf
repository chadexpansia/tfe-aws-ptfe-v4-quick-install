resource "aws_s3_bucket_policy" "tfe_app_bucket_policy" {
  bucket = aws_s3_bucket.tfe_app.id
  policy = data.template_file.tfe_s3_app_bucket_policy.rendered

  depends_on = [aws_s3_bucket_public_access_block.tfe_app_bucket_block_public]
}

resource "aws_s3_bucket_public_access_block" "tfe_app_bucket_block_public" {
  bucket = aws_s3_bucket.tfe_app.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true

  depends_on = [aws_s3_bucket.tfe_app]
}

################################################
# S3
################################################
resource "aws_s3_bucket" "tfe_app" {
  bucket = "${var.friendly_name_prefix}-tfe-app-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}-${random_string.key_name.result}"
  region = data.aws_region.current.name

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = var.kms_key_arn != "" ? var.kms_key_arn : ""
      }
    }
  }

  tags = merge(
    { Name = "${var.friendly_name_prefix}-tfe-app-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}" },
    { Description = "TFE object storage" },
    var.common_tags
  )
}

################################################
# S3
################################################
data "template_file" "tfe_s3_app_bucket_policy" {
  template = file("${path.module}/templates/tfe-s3-app-bucket-policy.json")

  vars = {
    tfe_s3_app_bucket_arn     = aws_s3_bucket.tfe_app.arn
    current_iam_caller_id_arn = data.aws_caller_identity.current.arn
    tfe_iam_role_arn          = aws_iam_role.tfe_instance_role.arn
  }
}

################################################
# IAM
################################################
data "template_file" "instance_role_policy_kms" {
  count    = var.kms_key_arn != "" ? 1 : 0
  template = file("${path.module}/templates/tfe-instance-role-policy-kms.json")

  vars = {
    tfe_s3_app_bucket_arn = aws_s3_bucket.tfe_app.arn
    aws_kms_arn           = var.kms_key_arn
  }
}

data "template_file" "instance_role_policy" {
  count    = var.kms_key_arn == "" ? 1 : 0
  template = file("${path.module}/templates/tfe-instance-role-policy.json")

  vars = {
    tfe_s3_app_bucket_arn = aws_s3_bucket.tfe_app.arn
  }
}

resource "aws_iam_role" "tfe_instance_role" {
  name                  = "${var.friendly_name_prefix}-tfe-instance-role-${data.aws_region.current.name}" #-${random_string.key_name.result}"
  path                  = "/"
  assume_role_policy    = file("${path.module}/templates/tfe-instance-role.json")
  force_detach_policies = true
  tags                  = merge({ Name = "${var.friendly_name_prefix}-tfe-instance-role" }, var.common_tags)
}

resource "aws_iam_role_policy" "tfe_instance_role_policy" {
  name   = "${var.friendly_name_prefix}-tfe-instance-role-policy-${data.aws_region.current.name}" #-${random_string.key_name.result}"
  policy = var.kms_key_arn != "" ? data.template_file.instance_role_policy_kms[0].rendered : data.template_file.instance_role_policy[0].rendered
  role   = aws_iam_role.tfe_instance_role.id
}

resource "aws_iam_instance_profile" "tfe_instance_profile" {
  name = "${var.friendly_name_prefix}-tfe-instance-profile-${data.aws_region.current.name}" #-${random_string.key_name.result}"
  path = "/"
  role = aws_iam_role.tfe_instance_role.name
}