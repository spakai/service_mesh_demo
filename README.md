# Service Mesh Demo

This repository demonstrates a simple service mesh scenario using Consul for service discovery. Two Flask services are provided and orchestrated using Docker Compose.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed on your machine
- [Docker Compose](https://docs.docker.com/compose/install/) or a Docker version that includes Compose

## Build and Run

1. Clone this repository and change into the directory.
2. Build and start the containers with `docker-compose`:
   ```bash
   docker-compose up --build
   ```
3. Access the Consul UI at [http://localhost:8500](http://localhost:8500).
4. Test Service A by visiting [http://localhost:5000/data](http://localhost:5000/data).
5. Test Service B which fetches data from Service A via Consul by visiting [http://localhost:5001/fetch](http://localhost:5001/fetch).

## Services

### service_a

A small Flask service that exposes an endpoint `/data` returning a JSON message and a `/health` endpoint for health checks. It registers itself with Consul using the configuration found in `service_a.hcl`.

### service_b

Another Flask service that queries Consul to discover `service_a`. It then requests data from `service_a` and exposes the result on `/fetch` together with its own status. A `/health` endpoint is also provided.


## Deploy on AWS using Terraform

You can run the demo on AWS instead of locally by provisioning an EC2 instance
that automatically starts the Docker Compose environment.

1. Install [Terraform](https://www.terraform.io/downloads).
2. Edit the variables in `terraform/variables.tf` if needed. At a minimum set
   `repo_url` to a repository that contains this project and `key_name` to an
   existing EC2 key pair. Optionally provide `public_key_path` to create the key
   pair automatically.
3. Initialise and apply the Terraform configuration:

   ```bash
   cd terraform
   terraform init
   terraform apply
   ```

After the apply completes, Terraform outputs the public IP address of the EC2
instance. The services will be accessible on the following ports:

- Consul UI: `http://34.237.137.146:8500`
- Service A: `http://<public_ip>:5000/data`
- Service B: `http://<public_ip>:5001/fetch`

# Service Mesh Demo on AWS with Terraform

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed and configured
- An AWS account with permissions to create VPCs, EC2, IAM, and Secrets Manager resources
- A valid EC2 key pair in your AWS region
- Your GitHub username and a [Personal Access Token (PAT)](https://github.com/settings/tokens) with repo access

## Setup Instructions

### 1. Clone this repository

```bash
git clone https://github.com/your-username/service_mesh_demo.git
cd service_mesh_demo/terraform
```

### 2. Configure variables

Edit `terraform.tfvars` or pass variables via CLI.  
**Do NOT commit your PAT or sensitive values.**

Example `terraform.tfvars` (do not commit this file!):
```hcl
region         = "us-east-1"
instance_type  = "t3.micro"
key_name       = "your-ec2-keypair"
github_username = "your-github-username"
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Apply Terraform configuration

**Pass your GitHub PAT securely via the CLI:**
```bash
terraform apply -var="github_pat=your-github-pat"
```
You will be prompted to approve the plan.

### 5. Access your EC2 instance

- After apply, Terraform will output the public IP of your EC2 instance.
- SSH into your instance:
  ```bash
  ssh -i /path/to/your-key.pem ec2-user@<public-ip>
  ```

### 6. What happens automatically

- A VPC, subnet, security group, and EC2 instance are created.
- An IAM role is attached to the instance to allow access to AWS Secrets Manager.
- Your GitHub PAT is stored in Secrets Manager.
- The EC2 instance installs Docker, Docker Compose, Git, and clones your private repo using the PAT.
- Docker Compose is run to start your application.

### 7. Destroy resources

When finished, clean up with:
```bash
terraform destroy -var="github_pat=your-github-pat"
```

---

## Security Notes

- **Never commit your GitHub PAT or any secrets to version control.**
- Use variables and `.tfvars` files for sensitive data, and add them to `.gitignore`.
- Rotate your PAT regularly and delete it if exposed.

---

## Troubleshooting

- If you see `Repository not found`, check your repo URL, branch, PAT, and username.
- If Docker Compose says `no configuration file provided`, ensure your repo contains a `docker-compose.yml` or `compose.yaml` at the root.
- If you get `Unable to locate credentials`, ensure your EC2 instance has the correct IAM role attached.

---
