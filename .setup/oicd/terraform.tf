terraform {
    required_version = ">= 1.0"

    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 6.0"
        }
    }
    
    backend "s3" {
        # Configuration will be loaded from oicd.hcl
    }
}