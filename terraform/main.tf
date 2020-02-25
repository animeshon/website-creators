provider "google" {
  version = "~> 3.6"
}

# NOTE: A new id is generated each time we switch to a new image tag.
resource "random_id" "comingsoon" {
  keepers = {
    image_tag = var.image_tag
  }

  byte_length = 8
}

resource "google_cloud_run_service" "comingsoon" {
  project  = data.terraform_remote_state.root.outputs.project_id
  location = "europe-west1"
  name     = "comingsoon-animeshon-com"

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "5"
        "run.googleapis.com/client-name"   = "cloud-console"
      }
      name = format("comingsoon-animeshon-com-%s", random_id.comingsoon.hex) 
    }

    spec {
      container_concurrency = 80
      service_account_name  = data.terraform_remote_state.root.outputs.compute_default_service_account_email

      containers {
        image = format("gcr.io/gcp-animeshon/comingsoon:%s", var.image_tag)

        env {
          name  = "HOST"
          value = "comingsoon.animeshon.com"
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

# Configure the domain name mapping for the instance to comingsoon.animeshon.com.
resource "google_cloud_run_domain_mapping" "comingsoon" {
  project  = google_cloud_run_service.comingsoon.project
  location = google_cloud_run_service.comingsoon.location
  name     = "comingsoon.animeshon.com"

  metadata {
    namespace = data.terraform_remote_state.root.outputs.project_id
  }

  spec {
    route_name = google_cloud_run_service.comingsoon.name
  }
}

# Allow everyone to access this instance from comingsoon.animeshon.com.
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "comingsoon" {
  project  = google_cloud_run_service.comingsoon.project
  location = google_cloud_run_service.comingsoon.location
  service  = google_cloud_run_service.comingsoon.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
