
locals {
  required_apis = [
    "storage.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com",
    "run.googleapis.com",
    "eventarc.googleapis.com"
  ]
}

resource "google_project_service" "apis1" {
  for_each = toset(local.required_apis)

  project                    = var.project_id
  service                    = each.value
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_storage_bucket" "function_bucket" {
  name          = var.existing_bucket_name
  project       = var.project_id
  location      = var.bucket_location
  force_destroy = true

  uniform_bucket_level_access = true
}

data "archive_file" "function_source" {
  type        = "zip"
  source_dir  = "${path.module}/function-source"
  output_path = "${path.module}/function-source.zip"
}

resource "google_storage_bucket_object" "function_source_zip" {
  name         = var.existing_object_name
  bucket       = google_storage_bucket.function_bucket.name
  source       = data.archive_file.function_source.output_path
  content_type = "application/zip"

  depends_on = [google_storage_bucket.function_bucket]
}

resource "google_cloudfunctions2_function_iam_member" "invoker" {
  project        = var.project_id
  location       = var.bucket_location
  cloud_function = google_cloudfunctions2_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
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

resource "time_sleep" "wait_for_apis" {
  create_duration = "90s"

  depends_on = [google_project_service.apis1]
}

resource "google_cloudfunctions2_function" "function" {
  name     = var.name
  location = var.bucket_location
  project  = var.project_id

  build_config {
    runtime     = var.environment_runtime
    entry_point = var.entry_point

    source {
      storage_source {
        bucket = google_storage_bucket.function_bucket.name
        object = google_storage_bucket_object.function_source_zip.name
      }
    }
  }

  depends_on = [time_sleep.wait_for_apis, google_storage_bucket_object.function_source_zip]

  service_config {
    max_instance_count            = var.max_instance_count
    available_memory              = var.available_memory
    timeout_seconds               = var.timeout_seconds
    ingress_settings              = var.ingress_settings
    vpc_connector                 = var.vpc_connector
    vpc_connector_egress_settings = "PRIVATE_RANGES_ONLY"
  }
}

# resource "google_project_iam_member" "gcf_network_user" {
#   project = var.host_project_id
#   role    = "roles/vpcaccess.user"
#   member  = "serviceAccount:service-${data.google_project.current.number}@gcf-admin-robot.iam.gserviceaccount.com"
# }
