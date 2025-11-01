# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "fs-0736c468520e3b993"
resource "aws_efs_file_system" "nextcloud_efs" {
  availability_zone_name          = null
  creation_token                  = "console-9babea01-6904-4f61-932e-e5918ec4b260"
  encrypted                       = true
  kms_key_id                      = "arn:aws:kms:sa-east-1:906116143348:key/be70f08b-7b1c-42ff-8389-e45ec32a286c"
  performance_mode                = "generalPurpose"
  provisioned_throughput_in_mibps = 0
  region                          = "sa-east-1"
  tags = {
    Name = "efs-nextcloud"
  }
  tags_all = {
    Name = "efs-nextcloud"
  }
  throughput_mode = "bursting"
  protection {
    replication_overwrite = "ENABLED"
  }
}
