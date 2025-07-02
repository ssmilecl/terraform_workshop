region      = "us-west-2"
project     = "terraform-workshop"
environment = "dev"
workspace_name = "prometheus-workshop"

tags = {
  Owner       = "DevOps"
  ManagedBy   = "Terraform"
}

# Example rule group namespace
rule_group_namespaces = {
  example = {
    name = "example"
    data = <<-EOT
      groups:
        - name: example
          rules:
            - record: job:up:sum
              expr: sum by(job) (up)
    EOT
  }
}

# Example alertmanager configuration
alertmanager_configuration = {
  data = <<-EOT
    alertmanager_config: |
      route:
        receiver: default
      receivers:
        - name: default
  EOT
}