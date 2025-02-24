# Terraform Workshop

This repository contains materials for learning Infrastructure as Code (IaC) with Terraform on AWS.

## Prerequisites

Before starting this workshop, please complete the following setup steps:

### 1. Fork this Repository

1. Click the "Fork" button at the top right of this repository
2. Clone your forked repository locally

### 2. Set Up AWS Account

1. Create a free AWS account if you don't have one
2. Create an IAM user with programmatic access and AdministratorAccess policy
3. Save the access key ID and secret access key
4. Configure AWS CLI with your credentials:
   ```bash
   aws configure
   ```

### 3. Install Terraform

1. Install Terraform CLI
   Follow the instructions at https://learn.hashicorp.com/tutorials/terraform/install-cli
   
   *You can also use tfenv to manage multiple versions of Terraform*
   
2. Verify installation:
   ```bash
   terraform --version
   ```