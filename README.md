# gcp-microservices-tf

Modular Terraform project for Google Cloud Platform (GCP) to host the **Online Boutique** app.

## Architecture Implemented

- **VPC**: `prod-vpc` with `routing_mode = "REGIONAL"`
- **Subnets**:
	- `gke-subnet` (GKE nodes/pods/services)
	- `serverless-subnet` (Serverless VPC Access)
- **Connectivity**:
	- Private Services Access peering (for Cloud SQL + Memorystore)
	- Cloud Router + Cloud NAT for private GKE egress
	- Serverless VPC Access connector for Cloud Run
- **Compute**:
	- Regional **GKE Standard** cluster (private nodes, Workload Identity)
	- Cloud Run frontend with **all egress through VPC connector**
- **Data**:
	- Cloud SQL PostgreSQL (private IP only)
	- Memorystore Redis Standard HA (private access)
- **Ops**:
	- Cloud Scheduler HTTP warm-up/health-check every 5 minutes
	- Persistent disk + Kubernetes StorageClass for stateful components

## Project Structure

```text
.
├── main.tf
├── outputs.tf
├── providers.tf
├── variables.tf
├── versions.tf
└── modules
		├── database
		│   ├── main.tf
		│   ├── outputs.tf
		│   └── variables.tf
		├── gke
		│   ├── main.tf
		│   ├── outputs.tf
		│   └── variables.tf
		├── network
		│   ├── main.tf
		│   ├── outputs.tf
		│   └── variables.tf
		└── serverless
				├── main.tf
				├── outputs.tf
				└── variables.tf
```

## Required Inputs

Set these in `terraform.tfvars` (or via `-var`):

```hcl
project_id   = "your-gcp-project-id"
region       = "us-central1"
cluster_name = "boutique-gke"
```

Optional:

```hcl
disk_zone = "us-central1-b"
```

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Python Deploy Script (gcloud SDK)

You can deploy infra + app in one flow with:

```bash
python3 deploy.py \
	--project-id your-gcp-project-id \
	--region us-central1 \
	--cluster-name boutique-gke \
	--auto-approve
```

Useful flags:

- `--skip-auth` (if already authenticated)
- `--skip-terraform` (deploy/update app only)
- `--skip-app` (infra only)
- `--tfvars-file path/to/terraform.tfvars`

## Outputs

- `gke_cluster_endpoint`
- `cloud_run_url`
- `database_private_ip`

