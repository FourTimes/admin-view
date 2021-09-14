resource "aws_dynamodb_table" "chatbot" {
  name           = "${var.project}-chatbot-${var.environment}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  stream_enabled = false
  hash_key       = "S.No"
  attribute {
    name = "ItemMenu"
    type = "S"
  }
  attribute {
    name = "S.No"
    type = "N"
  }
  attribute {
    name = "SubModule"
    type = "S"
  }
  attribute {
    name = "Topic"
    type = "S"
  }

  global_secondary_index {
    hash_key = "ItemMenu"
    name     = "ItemMenu"
    non_key_attributes = [
      "SubModule",
    ]
    projection_type = "INCLUDE"
    read_capacity   = 5
    write_capacity  = 5
  }

  point_in_time_recovery {
    enabled = false
  }

  tags = merge({ Name = "${var.project}-${var.environment}-dynamodb" }, tomap(var.additional_tags))
}
