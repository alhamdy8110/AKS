markdown

# AKS Deployment with Terraform and AGIC

This repository automates the deployment of an Azure Kubernetes Service (AKS) cluster, Azure Container Registry (ACR), NGINX application, and Application Gateway Ingress Controller (AGIC) using Terraform and GitHub Actions. It also installs cert-manager for certificate management and stores Terraform state in Azure Blob Storage.

## Table of Contents
- [Project Overview](#project-overview)
- [Prerequisites](#prerequisites)
- [Repository Structure](#repository-structure)
- [Setup Instructions](#setup-instructions)
- [GitHub Actions Workflows](#github-actions-workflows)
- [Usage](#usage)
- [Clean Up](#clean-up)
- [References](#references)

## Project Overview
This project uses Terraform to provision an AKS cluster, ACR, and Application Gateway, and GitHub Actions to deploy an NGINX application with the Application Gateway Ingress Controller (AGIC) for advanced load balancing and routing. Key components include:
- **AKS Cluster**: Hosts the NGINX application.
- **Azure Container Registry (ACR)**: Stores the NGINX container image.
- **Application Gateway Ingress Controller (AGIC)**: Integrates Azure Application Gateway with AKS for ingress routing.
- **Cert-manager**: Manages certificates for secure ingress.
- **Terraform Backend**: Stores state in Azure Blob Storage, configured via `backend-setup/main.tf`.

The deployment is orchestrated via GitHub Actions workflows, with Terraform configurations modularized for clarity and reusability.

## Prerequisites
- An Azure subscription with permissions to create resources.
- A Service Principal with `Contributor` role on the subscription.
- GitHub repository secrets configured:
  - `AZURE_CLIENT_ID`: Service Principal Client ID
  - `AZURE_CLIENT_SECRET`: Service Principal Client Secret
  - `AZURE_SUBSCRIPTION`: Azure Subscription ID
  - `AZURE_TENANT_ID`: Azure Tenant ID
- Terraform installed locally (optional, for manual runs).
- Helm and kubectl installed locally (optional, for debugging).
- Docker installed (optional, for building images locally).

## Repository Structure

├── aks/                    # Terraform configurations for AKS, ACR, and Application Gateway
│   ├── backend.tf         # Terraform backend configuration for Azure Blob Storage
│   ├── main.tf            # Main Terraform configuration for AKS, ACR, and Application Gateway
│   ├── outputs.tf         # Terraform output variables
│   ├── providers.tf       # Terraform provider configurations (e.g., AzureRM)
│   ├── ssh.tf             # SSH key configuration for AKS nodes
│   ├── variables.tf       # Input variables for Terraform configurations
├── backend-setup/          # Terraform configuration for Azure Blob Storage (state backend)
│   ├── main.tf            # Configuration for Azure Blob Storage backend
├── k8s/                    # Kubernetes manifests for NGINX, ingress, and cert-manager
│   ├── nginx-deployment.yml
│   ├── ingress.yml
│   ├── issuer.yml
├── tf-outputs.env          # Generated Terraform output variables
└── .github/workflows/      # GitHub Actions workflows
    ├── aks-deployment.yml  # Workflow for AKS deployment
    ├── aks-destroy.yml     # Workflow for AKS cleanup
    ├── deploy-nginx.yml    # Workflow for NGINX and AGIC deployment

## Setup Instructions
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/<your-username>/<your-repo>.git
   cd <your-repo>

Configure Azure Credentials:
Create a Service Principal:
bash

az ad sp create-for-rbac --name "myAKSApp" --role Contributor --scopes /subscriptions/<subscription-id>

Store the output values (appId, password, tenant) as GitHub Secrets (AZURE_CLIENT_ID, AZURE_CLIENT_SECRET, AZURE_TENANT_ID, AZURE_SUBSCRIPTION).

Set Up Terraform Backend:
Update backend-setup/main.tf to define your Azure Blob Storage account and container for Terraform state.

Update aks/backend.tf to reference the Blob Storage backend configured in backend-setup/main.tf.

Refer to Store Terraform state in Azure Blob Storage for guidance.

Customize Terraform Configurations:
Modify aks/main.tf to configure AKS, ACR, and Application Gateway resources.

Update aks/variables.tf with desired input values (e.g., resource group name, AKS cluster name).

Configure aks/ssh.tf with SSH key details for AKS node access.

Review aks/outputs.tf to ensure required outputs (e.g., resource_group_name, aks_cluster_name, app_gateway_id) are defined.

Customize Kubernetes Manifests:
Update k8s/nginx-deployment.yml, k8s/ingress.yml, and k8s/issuer.yml to match your NGINX and AGIC configurations.

Ensure ingress.yml includes AGIC-specific annotations (e.g., kubernetes.io/ingress.class: azure/application-gateway).

Push to GitHub:
Commit and push your changes to trigger the GitHub Actions workflows.

GitHub Actions Workflows
This repository includes three workflows:
AKS Deployment (aks-deployment.yml):
Initializes and applies Terraform in backend-setup to configure the Azure Blob Storage backend.

Initializes and applies Terraform in aks to deploy AKS, ACR, and Application Gateway.

Exports Terraform outputs (e.g., resource_group_name, aks_cluster_name, app_gateway_id) to tf-outputs.env and commits them to the repository.

Triggered manually via workflow_dispatch.

AKS Destroy (aks-destroy.yml):
Destroys the AKS infrastructure using Terraform in the aks directory.

Deletes the resource group (rg-aks) using the Azure CLI.

Removes tf-outputs.env from the repository.

Triggered manually via workflow_dispatch.

Deploy NGINX to AKS (deploy-nginx.yml):
Logs into Azure using Service Principal credentials.

Attaches ACR to AKS and pushes the NGINX image to ACR.

Installs cert-manager for certificate management.

Installs AGIC using Helm and configures federation with AKS OIDC issuer.

Deploys NGINX application and ingress configurations to AKS using manifests in k8s/.

Triggered manually via workflow_dispatch.

For additional details, see the references listed at the bottom of the workflow files in .github/workflows/ (e.g., aks-deployment.yml, aks-destroy.yml, deploy-nginx.yml).
Usage
Deploy AKS Infrastructure:
Navigate to the "Actions" tab in your GitHub repository.

Select the aks Deployment workflow and click "Run workflow".

Deploy NGINX and AGIC:
After AKS deployment completes, run the Deploy Nginx to aks workflow from the "Actions" tab.

Access the Application:
Retrieve the public IP or DNS name of the Application Gateway from the Azure portal or Terraform outputs in aks/outputs.tf.

Access the NGINX application via the configured ingress URL (ensure k8s/ingress.yml specifies AGIC with appropriate annotations).

Clean Up:
Run the aks Destroy workflow to delete all resources and clean up the repository.

Clean Up
To avoid Azure charges, destroy the infrastructure when no longer needed:
Run the aks Destroy workflow from the GitHub Actions tab.

Verify resource deletion in the Azure portal.

References
For detailed setup and additional resources, refer to the URLs listed at the bottom of the GitHub Actions workflow files in .github/workflows/:

- https://github.com/hashicorp/setup-terraform

- https://learn.microsoft.com/en-us/devops/deliver/iac-github-actions#deploy-with-github-actions

- https://github.com/Azure/actions-workflow-samples?tab=readme-ov-file

- https://azure.github.io/actions/

- https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage

- https://docs.github.com/en/actions/use-cases-and-examples/deploying/deploying-to-azure-kubernetes-service

- https://github.com/marketplace/actions/azure-login#login-with-a-service-principal-secret

- https://cert-manager.io/docs/installation/helm/


Notes
Contributing Removed: The "Contributing" section and its corresponding Table of Contents entry have been removed as requested.

References: The README includes a note in the "GitHub Actions Workflows" section and a "References" section, pointing to the URLs at the bottom of the workflow files.

Project Structure: The README accurately reflects the backend-setup/main.tf file and the aks/ directory files (backend.tf, main.tf, outputs.tf, providers.tf, ssh.tf, variables.tf).

AGIC Focus: The README focuses on AGIC as the ingress controller, omitting the NGINX Ingress Controller since it’s commented out in deploy-nginx.yml.

Customization: Replace <your-username> and <your-repo> with your actual GitHub details. If you have specific configurations in aks/main.tf, aks/variables.tf, or backend-setup/main.tf (e.g., resource names, regions), share them for further tailoring.

Manifests: Ensure k8s/ingress.yml uses AGIC-specific annotations (e.g., kubernetes.io/ingress.class: azure/application-gateway).

Security: Verify that GitHub Secrets are securely configured and not exposed.

