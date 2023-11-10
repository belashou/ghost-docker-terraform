resource "aws_s3_bucket" "app_data" {
  bucket = "${var.app_bucket_name}"

  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket" "app_data_backup" {
  bucket = "${var.app_backup_bucket_name}"

  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
}
