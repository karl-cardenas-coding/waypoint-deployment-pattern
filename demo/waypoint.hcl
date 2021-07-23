project = "example-go"

runner {
  enabled = true

  data_source "git" {
    url  = "https://github.com/karl-cardenas-coding/waypoint-examples.git"
    path = "docker/go"
  }
}

app "example-go" {
  labels = {
    "service" = "example-go",
    "env"     = "dev"
  }
  
   url {
    auto_hostname = false
  }

  build {
    use "pack" {}
  }
  
   deploy {
      use "docker" {
        service_port = 3000
      }
  }
}