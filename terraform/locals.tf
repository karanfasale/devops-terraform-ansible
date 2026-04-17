locals {
  project_name = "terraform-ansible-project"
  environment  = "dev"

  common_tags = {
    Project     = local.project_name
    Environment = local.environment
  }
}
