provider "google" {
  project = var.project_id
  region  = var.bucket_location
}

resource "google_cloudfunctions_function" "function" {
  name        = var.function_name
  runtime     = var.environment_runtime
  region      = var.bucket_location
  project     = var.project_id
  entry_point = var.entry_point

  # Reference existing bucket/object
  source_archive_bucket = var.existing_bucket_name
  source_archive_object = var.existing_object_name

  trigger_http = true

  available_memory_mb = var.available_memory
  timeout             = var.timeout_seconds

  #  VPC access
  vpc_connector                  = var.vpc_connector
  vpc_connector_egress_settings = var.vpc_connector_egress_settings
  ingress_settings              = var.ingress_settings

  environment_variables = {
    GOOGLE_FUNCTION_SOURCE = "main.py"
  }

  lifecycle {
    ignore_changes = [
      entry_point,
      source_archive_bucket,
      source_archive_object
    ]
  }
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = var.project_id
  region         = var.bucket_location
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

resource "google_project_iam_member" "gcf_network_user" {
  project = var.host_project_id 
  role    = "roles/vpcaccess.user"
  member  = "serviceAccount:service-${data.google_project.current.number}@gcf-admin-robot.iam.gserviceaccount.com"
}


resource "google_project_iam_member" "compute_storage_viewer" {
  project = var.project_id  
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${data.google_project.current.number}-compute@developer.gserviceaccount.com"
}


resource "google_project_iam_member" "compute_cloudbuild" {
  project = var.project_id 
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${data.google_project.current.number}-compute@developer.gserviceaccount.com"
}


data "google_project" "current" {
  project_id = var.project_id
}