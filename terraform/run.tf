locals {
  project         = data.terraform_remote_state.general.outputs.project_id
  service_account = data.terraform_remote_state.general.outputs.google_compute_default_service_account_email
}

# NOTE: A new id is generated each time we switch to a new image tag.
resource "random_id" "creators" {
  keepers = {
    image_tag = var.image_tag
  }

  byte_length = 8
}

resource "google_cloud_run_service" "creators" {
  project  = local.project
  location = "europe-west1"
  name     = "creators-animeshon-com"

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "5"
        "run.googleapis.com/client-name"   = "cloud-console"
      }
      name = format("creators-animeshon-com-%s", random_id.creators.hex) 
    }

    spec {
      container_concurrency = 80
      service_account_name  = local.service_account

      containers {
        image = format("gcr.io/gcp-animeshon-general/creators-animeshon-com:%s", var.image_tag)

        env {
          name  = "HOST"
          value = "creators.animeshon.com"
        }

        resources {
          limits = {
            cpu    = "1000m"
            memory = "256Mi"
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Configure the domain name mapping for the instance to creators.animeshon.com.
resource "google_cloud_run_domain_mapping" "creators" {
  project  = google_cloud_run_service.creators.project
  location = google_cloud_run_service.creators.location
  name     = "creators.animeshon.com"

  metadata {
    namespace = local.project
  }

  spec {
    route_name = google_cloud_run_service.creators.name
  }
}

# Allow everyone to access this instance from creators.animeshon.com.
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "creators" {
  project  = google_cloud_run_service.creators.project
  location = google_cloud_run_service.creators.location
  service  = google_cloud_run_service.creators.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
