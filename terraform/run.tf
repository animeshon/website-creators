
# NOTE: A new id is generated each time we switch to a new image tag.
resource "random_id" "comingsoon" {
  keepers = {
    image_tag = var.image_tag
  }

  byte_length = 8
}

resource "google_cloud_run_service" "comingsoon" {
  project  = local.project_id
  location = "europe-west1"
  name     = "artists-animeshon-com"

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "5"
        "run.googleapis.com/client-name"   = "cloud-console"
      }
      name = format("artists-animeshon-com-%s", random_id.comingsoon.hex) 
    }

    spec {
      container_concurrency = 80
      service_account_name  = local.sa_compute_email

      containers {
        image = format("gcr.io/gcp-animeshon-general/artists-animeshon-com:%s", var.image_tag)

        env {
          name  = "HOST"
          value = "artists.animeshon.com"
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

# Configure the domain name mapping for the instance to artists.animeshon.com.
resource "google_cloud_run_domain_mapping" "comingsoon" {
  project  = google_cloud_run_service.comingsoon.project
  location = google_cloud_run_service.comingsoon.location
  name     = "artists.animeshon.com"

  metadata {
    namespace = local.project_id
  }

  spec {
    route_name = google_cloud_run_service.comingsoon.name
  }
}

# Allow everyone to access this instance from artists.animeshon.com.
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
