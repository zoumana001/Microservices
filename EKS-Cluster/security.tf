# Kyverno for Policy Management
resource "helm_release" "kyverno" {
  name       = "kyverno"
  repository = "https://kyverno.github.io/kyverno"
  chart      = "kyverno"
  namespace  = "kyverno"
  version    = "3.1.4"
  create_namespace = true

  values = [
    <<EOF
features:
  policyExceptions:
    enabled: true
  reports:
    enabled: true
admissionController:
  replicas: 3
  service:
    type: ClusterIP
EOF
  ]

  depends_on = [aws_eks_node_group.main]
}

# Kyverno Policies
resource "kubectl_manifest" "kyverno_policies" {
  depends_on = [helm_release.kyverno]
  yaml_body  = <<YAML
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-labels
spec:
  validationFailureAction: Enforce
  rules:
    - name: check-for-labels
      match:
        any:
        - resources:
            kinds:
              - Pod
      validate:
        message: "label 'app' and 'environment' are required"
        pattern:
          metadata:
            labels:
              app: "?*"
              environment: "?*"
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-latest-tag
spec:
  validationFailureAction: Enforce
  rules:
    - name: require-image-tag
      match:
        any:
        - resources:
            kinds:
              - Pod
      validate:
        message: "Using 'latest' tag is not allowed"
        pattern:
          spec:
            containers:
              - image: "!*:latest"
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-pod-antiaffinity
spec:
  validationFailureAction: Enforce
  rules:
    - name: pod-antiaffinity
      match:
        any:
        - resources:
            kinds:
              - Deployment
              - StatefulSet
      validate:
        message: "Pod anti-affinity is required for high availability"
        pattern:
          spec:
            template:
              spec:
                affinity:
                  podAntiAffinity:
                    preferredDuringSchedulingIgnoredDuringExecution:
                      - podAffinityTerm:
                          labelSelector:
                            matchLabels:
                              app: "?*"
                          topologyKey: "topology.kubernetes.io/zone"
                        weight: 100
YAML
}

# Network Policies
resource "kubectl_manifest" "network_policies" {
  depends_on = [aws_eks_node_group.main]
  yaml_body  = <<YAML
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: default
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
  namespace: default
spec:
  podSelector: {}
  policyTypes:
    - Egress
  egress:
    - to:
        - namespaceSelector: {}
      ports:
        - protocol: UDP
          port: 53
YAML
}
