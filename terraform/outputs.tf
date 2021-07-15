output "waypoint-domain-url" {
  value = "https://${var.domain-name}"
}


output "waypoint-runner-app-url" {
  value = "http://${module.alb-runners.lb_dns_name}"
}