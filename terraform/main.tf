provider "google" {
  version = "~> 3.6"
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
    }

    spec {
      container_concurrency = 80
      service_account_name  = data.terraform_remote_state.root.outputs.compute_default_service_account_email

      containers {
        image = "gcr.io/gcp-animeshon/comingsoon@sha256:118ef31eae6d5a2f4256f798d18b15392e54934ce3a534429a191ff3c6ef9192"

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
