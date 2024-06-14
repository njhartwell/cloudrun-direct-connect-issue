module "cloud_run" {
  for_each = {
    all          = "ALL_TRAFFIC"
    private-only = "PRIVATE_RANGES_ONLY"
  }
  source          = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/cloud-run-v2?ref=v31.0.0&depth=1"
  project_id      = module.cloudrun_project.project_id
  name            = "test-${each.key}"
  region          = "us-central1"
  service_account = module.cloudrun_service_account.email
  containers      = {
    connection-tester = {
      image   = "curlimages/curl:8.8.0"
      command = ["time", "curl", "-s", "--connect-timeout", "5", "https://postman-echo.com/get"]
    }
  }
  revision = {
    gen2_execution_environment = true
    min_instance_count         = 1
    max_instance_count         = 2
    vpc_access                 = {
      egress = each.value
      subnet = module.vpc.subnets["us-central1/us-central1-cloudrun"].id
    }
  }
  iam = {
    "roles/run.invoker" = ["allUsers"]
  }
}
#module "cloud_run_job" {
#  source          = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/cloud-run-v2?ref=v31.0.0&depth=1"
#  project_id      = module.cloudrun_project.project_id
#  name            = "connection-tester-job"
#  region          = "us-central1"
#  service_account = module.cloudrun_service_account.email
#  create_job      = true
#  containers      = {
#    connection-tester = {
#      image   = "curlimages/curl:8.8.0"
#      command = ["time", "curl", "-s", "--connect-timeout", "5", "https://postman-echo.com/get"]
#    }
#  }
#  revision = {
#    gen2_execution_environment = true
#    min_instance_count         = 1
#    max_instance_count         = 2
#    vpc_access                 = {
#      egress = "ALL_TRAFFIC"
#      subnet = module.vpc.subnets["us-central1/us-central1-cloudrun"].id
#    }
#  }
#}
module "cloudrun_service_account" {
  source            = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/iam-service-account?ref=v31.0.0"
  name              = "poc-run"
  project_id        = module.cloudrun_project.project_id
  iam_project_roles = {
    (module.cloudrun_project.project_id) : [
      "roles/monitoring.metricWriter",
      "roles/cloudtrace.agent",
      "roles/logging.logWriter",
      "roles/cloudsql.client",
    ]
  }
}
