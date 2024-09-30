
resource "random_id" "generator" {
  byte_length = 4
}

resource "aws_ecr_repository" "docker_repository" {
  name = "private_docker_repo-${var.aws_region}-${random_id.generator.hex}"
  force_delete = true
}

data "aws_ecr_lifecycle_policy_document" "keep_only_5" {
  rule {
    priority    = 1
    description = "This is a lifecycle policy which only keeps the most recent 5 tagged images."

    selection {
      tag_status      = "tagged"
      tag_prefix_list = ["${var.image_tag}"]
      count_type      = "imageCountMoreThan"
      count_number    = 5
    }
  }
}

resource "aws_ecr_lifecycle_policy" "ecr_policy_attachment" {
  policy     = data.aws_ecr_lifecycle_policy_document.keep_only_5.json
  repository = aws_ecr_repository.docker_repository.name
}
