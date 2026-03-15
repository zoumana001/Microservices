variable "enable_gpu_nodes" {
  description = "Enable GPU node group for ML workloads"
  type        = bool
  default     = false
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.30"
}

variable "node_desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 3
}

variable "node_max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 5
}

variable "node_min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 3
}

variable "spot_node_desired_size" {
  description = "Desired number of spot nodes"
  type        = number
  default     = 3
}

variable "spot_node_max_size" {
  description = "Maximum number of spot nodes"
  type        = number
  default     = 5
}

variable "spot_node_min_size" {
  description = "Minimum number of spot nodes"
  type        = number
  default     = 3
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "microservices-platform"
}
