# Bites

Entire IT stack for webapp


## Get Started

Requirements:

- Terraform CLI installed
- AWS CLI installed
- AWS CLI user/key configured

```bash
cd terraform

terraform init
terraform apply

# Update password in AWS RDS instance manually

cd ../ansible

# Set "db_password" and "github_maven_pat" in vault.yml

ansible-galaxy install -r requirements.yml
ansible-playbook build-deploy-fruit-instances.yml -i inventory -e @vault.yml --ask-vault-pass
ansible-playbook install-nginx-proxy.yml -i inventory
ansible-playbook install-new-relic-infra.yml -i inventory -e @vault.yml --ask-vault-pass

```

## MVP Requirements

- All secrets/config properties are stored in .env
- Deploy Infrastructure via Terraform
    - Internal network for DB/Backend/Load balancer communication
    - CDN for webapp
    - DB for API
    - 3 app instances for backend
    - Load balancer for backend
    - AWS Deployment
    - ElasticStack for logging
    - Jaeger for app monitoring
    - Prometheus/Grafana for infrastructure monitoring
- Deploy Code changes via Github Actions
- Web app letting a user "eat" an apple
    - Upon page load, request fruit info for apple in /fruits endpoint
    - Reset button allows you to eat another apple
        - requests new meal id and stores in session storage (we don't want a user to come back to a rotten apple)
    - Apple bites and complete consumption are tracked via /bites API call
- Spring Boot backend to fruits, meals, and bites information
    - /meals POST endpoint
        - Creates a new meal id
        - Returns meal id
    - /bites POST endpoint
        - Records a bite event occurring
        - Collects info for geolocation purposes (IP or other data)
        - Sends meal id to track bites
        - Returns meal id, fruit id, bites left
        - On invalid meal id, return 404
        - On no more bites available, return 400
    - /fruits GET endpoint
        - Generic information about current fruit to bite
    - DB contains fruit configuration data (how many bites it takes, name)

## Wishlist

- Websocket in Spring Boot to show live locations on map of any bites taken with a 30 second fade-out
- Kubernetes version of the app
- Ansible for configuration management
- Feedback form utilizing serverless function to send email/slack message/etc
- Fullstory integration for troubleshooting
- VPN to internal 'corporate' network
- Istio Service Mesh
- Use GraalVM and/or Quarkus
- Global Aurora DB cluster
- AWS Global Accelerator (US East, US West, Europe, Asia)
