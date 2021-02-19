terraform {
  required_version = ">= 0.13"

  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "0.8.2"
    }
  }
}