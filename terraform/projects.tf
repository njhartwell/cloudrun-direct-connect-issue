locals {
  vpc_name = "vpc"
  regions  = ["us-central1"]
}

module "folder" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/folder?ref=v29.0.0"
  name   = var.folder_name
  parent = "organizations/${var.organization_id}"
}

module "network_project" {
  source                 = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/project?ref=v29.0.0&depth=1"
  billing_account        = var.billing_account_id
  prefix                 = var.project_prefix
  name                   = "cr-poc-network"
  parent                 = module.folder.id
  shared_vpc_host_config = {
    enabled = true
  }
  services = [
    "compute.googleapis.com"
  ]
}

module "cloudrun_project" {
  source          = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/project?ref=v29.0.0&depth=1"
  billing_account = var.billing_account_id
  prefix          = var.project_prefix
  name            = "cr-poc-cloudrun"
  parent          = module.folder.id
  services        = [
    "artifactregistry.googleapis.com",
    "compute.googleapis.com",
    "run.googleapis.com",
    "servicenetworking.googleapis.com",
  ]
  shared_vpc_service_config = {
    host_project       = module.network_project.project_id
    service_iam_grants = [
      "artifactregistry.googleapis.com",
      "compute.googleapis.com",
      "run.googleapis.com",
      "servicenetworking.googleapis.com",
    ]
    service_identity_iam = {
      "roles/compute.networkUser" = ["cloudrun"]
    }
  }
}

module "vpc" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/net-vpc/?ref=v29.0.0"
  project_id = module.network_project.project_id
  name       = local.vpc_name
  subnets    = [
    {
      ip_cidr_range = "10.0.0.0/24"
      name          = "us-central1-cloudrun"
      region        = "us-central1"
    },
  ]
}

module "nat" {
  for_each       = toset(local.regions)
  source         = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/net-cloudnat/?ref=v29.0.0"
  project_id     = module.network_project.project_id
  region         = each.value
  name           = "nat-${each.value}"
  router_network = module.vpc.name
}

