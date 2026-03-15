# CloudWatch Observability Addon
resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "amazon-cloudwatch-observability"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_node_group.main]
}

# Prometheus and Grafana via Helm
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  version    = "58.0.0"
  create_namespace = true

  values = [
    <<EOF
grafana:
  enabled: true
  adminPassword: ${random_password.grafana_admin.result}
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: alb
      alb.ingress.kubernetes.io/scheme: internal
      alb.ingress.kubernetes.io/target-type: ip
    hosts:
      - grafana.${local.name_prefix}.internal

prometheus:
  prometheusSpec:
    retention: 15d
    resources:
      requests:
        cpu: 500m
        memory: 2Gi
      limits:
        cpu: 1000m
        memory: 4Gi

alertmanager:
  enabled: true
EOF
  ]

  depends_on = [aws_eks_node_group.main]
}

resource "random_password" "grafana_admin" {
  length  = 16
  special = false
}

# Fluent Bit for log forwarding
resource "helm_release" "fluentbit" {
  name       = "fluentbit"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  namespace  = "logging"
  version    = "0.44.0"
  create_namespace = true

  values = [
    <<EOF
config:
  outputs: |
    [OUTPUT]
        Name cloudwatch_logs
        Match *
        region ${local.region}
        log_group_name /eks/${module.eks.cluster_name}/containers
        log_stream_prefix from-fluent-bit-
        auto_create_group true
EOF
  ]

  depends_on = [aws_eks_node_group.main]
}
