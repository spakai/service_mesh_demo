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

- Consul UI: `http://<public_ip>:8500`
- Service A: `http://<public_ip>:5000/data`
- Service B: `http://<public_ip>:5001/fetch`
