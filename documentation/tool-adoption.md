# Tool Adoption
There are of course exceptions to all guidelines/rules in engineering. The idea of curating technology is to ensure that maintenance does not become an enormous burden with a diverse skillset requirement.

## Guidelines
- A new tool must solve a problem
    - Generalized tool is perferred over tools that solve a specific problem
- Data persistence must use PostgreSQL as a storage backend unless it doesn't make sense for a tool to use a relational database as a storage backend
- Tools which are written in the general purpose language are preferred

### Infrastructure Provisioning/Configuration: Terraform
### Runtime: EKS
### Data Persistence Backend: PostreSQL + Local EBS Volumes
### Object Storage Backend: MinIO + Local EBS Volumes
### Secret Management: Vault
### Automation: Concourse CI
### Message Queue:
### General Purpose Language: Golang
### Telemetry Collection/Processing: OpenTelemetry
### Dashboards:
### Metrics backend:
### Traces backend:
### Logs backend: