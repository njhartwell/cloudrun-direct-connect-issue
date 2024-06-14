terraform {
  # This project intentionally uses local state
  # to facilitate local development
}

provider "google" {
  region  = "us-central1"
}
