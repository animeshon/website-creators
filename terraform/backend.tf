terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "animeshon"

    workspaces {
      name = "comingsoon-"
    }
  }
}

data "terraform_remote_state" "root" {
  backend = "remote"

  config = {
    hostname = "app.terraform.io"
    organization = "animeshon"

    workspaces = {
      name = "master"
    }
  }
}