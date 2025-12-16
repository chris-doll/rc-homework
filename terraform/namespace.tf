provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace_v1" "rc_homework" {
  metadata {
    name = "homework"
  }
}
