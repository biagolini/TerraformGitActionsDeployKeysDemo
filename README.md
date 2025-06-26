# Terraform GitHub Actions: Multi-Lambda Deployment with SSH Deploy Keys

This repository demonstrates a secure and modular approach to deploying multiple **AWS Lambda** functions using **Terraform** and **GitHub Actions**, with source code pulled from **private GitHub repositories** via **SSH deploy keys**.

Authentication to AWS is performed via **OpenID Connect (OIDC)**, eliminating the need for static credentials.

---

## Project Structure

```
TerraformGitActionsDeployKeysDemo/

├── module/                       # Reusable Terraform module for Lambda deployment
│   ├── main.tf
│   └── variables.tf
│
├── environments/                # Environment-specific configurations
│   └── dev/
│       ├── main.tf              # Module instantiation
│       ├── variables.tf         # Variables used by the environment
│       ├── terraform.tfvars     # Lambda definitions (repo, runtime, ssh key, etc.)
│       └── providers.tf         # AWS provider + remote backend
│
.github/
└── workflows/
    └── terraform.yml            # CI/CD pipeline for Terraform
```

---

## Key Features

* **Multiple Lambda functions**, each pulled from a private GitHub repository
* **SSH Deploy Keys**: One key per Lambda ensures isolated access
* **CI/CD via GitHub Actions**: Automates plan/apply steps securely
* **State locking**: Managed using S3 + DynamoDB backend

---

## Local Development Instructions

To deploy the `dev` environment manually:

```bash
cd environments/dev

# Initialize Terraform and connect to remote backend
terraform init

# Validate config
terraform validate

# Review planned infrastructure changes
terraform plan -var-file=terraform.tfvars

# Apply the changes
terraform apply -auto-approve -var-file=terraform.tfvars
```

Ensure your AWS credentials are correctly configured (via `aws configure`, environment variables, or assumed role).

---

## Backend Setup (One-Time Manual Step)

Before running `terraform init`, the remote state backend must be provisioned:

```bash
aws s3api create-bucket \
  --bucket tutorial-terraform-tfstate \
  --region us-east-1 \
  --create-bucket-configuration LocationConstraint=us-east-1

aws dynamodb create-table \
  --table-name terraform-lock-table \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

---

## CI/CD with GitHub Actions

### Secrets Required

Under **Settings > Secrets and Variables > Actions**, define:

* `AWS_ROLE_ARN` — OIDC-enabled IAM role to assume
* `AWS_REGION` — e.g., `us-east-1`
* `KEY_01`, `KEY_02`, ... — The private deploy keys used to clone private Lambda repos

### Deploy Keys

Each Lambda's repository must:

* Add its **public key** (e.g., `key_01.pub`) under **Settings > Deploy Keys**
* Ensure "Allow write access" is **unchecked**

### Workflow Summary

On each `push` to `main`, the workflow will:

1. Checkout the Terraform repo
2. Inject SSH private keys into `~/.ssh`
3. Authenticate to AWS via OIDC
4. Run `terraform init`, `validate`, `plan`, `apply`
5. For each Lambda:

   * Clone the private repo with SSH
   * Package it into a ZIP
   * Deploy with Terraform

---

## Security Notes

* **IAM Role** used by GitHub Actions should have only the necessary permissions:

  * `lambda:*` (for full Lambda control)
  * Minimal `s3`/`dynamodb` access for backend
  * `iam:GetRole`, `iam:PassRole`, and `iam:ListRolePolicies` for managing Lambda IAM roles

* Avoid committing any private keys; use **GitHub Secrets** exclusively

* Each Lambda should use a unique SSH key for least-privilege access

---

## Extend the Project

You can:

* Add more Lambdas by updating `terraform.tfvars` and adding new keys
* Create multiple environments (`prod/`, `staging/`, etc.)
* Parameterize further with modules for common Lambda patterns (e.g., container-based, layer-based)

---

## Author

**LinkedIn:** [https://www.linkedin.com/in/biagolini](https://www.linkedin.com/in/biagolini)
**GitHub:** [https://github.com/biagolini](https://github.com/biagolini)
**Medium:** [https://medium.com/@biagolini](https://medium.com/@biagolini)
**YouTube (PT-BR):** [https://www.youtube.com/@BiagoliniTech](https://www.youtube.com/@BiagoliniTech)
