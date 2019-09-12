output "kube_config" {
    value = "${azurerm_kubernetes_cluster.aks.kube_config_raw}"
}

output "lb_ip" {
  value = kubernetes_service.nginx.load_balancer_ingress[0].ip
}
