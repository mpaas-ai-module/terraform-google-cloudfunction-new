variable "project_id" {
  type        = string
  description = "GCP project ID where resources will be created"
}

variable "bucket_location" {
  type        = string
  description = "The location for the GCS bucket"
}
variable "environment_runtime" {
  type        = string
  description = "the environment"
}
variable "entry_point" {
  type        = string
  description = "the definiton of cloud run function"
}
variable "function_name" {
  type        = string
  description = "The name of the Cloud Function"
}

variable "vpc_connector" {
  type        = string
  description = "Full resource ID of the VPC connector"
}

variable "bucket_name_prefix" {
  type        = string
  description = "Prefix for the GCS bucket name"
}

variable "vpc_connector_egress_settings" {
  type        = string
  default     = "PRIVATE_RANGES_ONLY"
  description = "Egress settings for the VPC connector"
}

variable "ingress_settings" {
  type        = string
  default     = "ALLOW_INTERNAL_AND_GCLB"
  description = "Ingress settings for the Cloud Function"
}

variable "available_memory" {
  type        = number
  default     = 256
  description = "Memory available to the function"
}

variable "timeout_seconds" {
  type        = number
  default     = 60
  description = "Timeout for the function execution"
}

variable "max_instance_count" {
  type        = number
  default     = 1
  description = "Maximum number of instances"
}
variable "existing_bucket_name" {
  type        = string
  description = "the cloud storage bucket"
}
variable "existing_object_name" {
  type        = string
  description = "The zip file of the bucket"
}
 
variable "host_project_id" {
  description = "The host project ID where IAM bindings should be applied"
  type        = string
}