terraform {
  backend "remote" {
    # organization = "<replace-with-your-Terraform-Cloud-organization-and-uncomment>"
    workspaces {
      name = "ace-automation-day-two"
    }
  }
  required_providers {
    aviatrix = {
      source  = "AviatrixSystems/aviatrix"
      version = "~> 3.1.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2"
}
