## Project name
Terraform resources

## Table of contents
- [Project name](#project-name)
- [Table of contents](#table-of-contents)
- [General info](#general-info)
- [Technologies](#technologies)
- [Setup](#setup)
  - [Terraform examples](#terraform-examples)
  - [GCP modules setup](#gcp-modules-setup)
  - [Azure modules setup](#azure-modules-setup)
- [Usage](#usage)

## General info
Terraform modules and examples created for learning purposes.

## Technologies
- Terraform
- HCL language

## Setup

### Terraform examples

1) Install terraform
2) Create terraform service account
3) Reconfigure variables in *main.tf* file
4) Download JSON file with SA key
5) Ensure that all required API's are enabled (especially cloudresourcemanager.googleapis.com)
6) Expose required variables
      ```
      export GOOGLE_APPLICATION_CREDENTIALS="path/to/file.json"
      export GOOGLE_PROJECT="myproject
      export GOOGLE_REGION="us-central1"
      export GOOGLE_ZONE="us-central1-b"
      ```

### GCP modules setup

1) Create requried minimal structure (*main.tf*, *terraform.tf* and *variables.tf*).
   Check please terraform documentation for more details.
2) Expose required variables:
3)    ```
      export GOOGLE_APPLICATION_CREDENTIALS="path/to/file.json"
      export GOOGLE_PROJECT="myproject
      export GOOGLE_REGION="us-central1"
      export GOOGLE_ZONE="us-central1-b"
      ```

### Azure modules setup

1) Create requried minimal structure (*main.tf*, *terraform.tf* and *variables.tf*). 
   Check please terraform documentation for more details.
2) Expose required variables:
3)    ```
      ARM_CLIENT_ID="7b693051-1605-4db8-93d6-99d9cd1610fb"
      ARM_CLIENT_SECRET="somefakesecret-123~abc"
      ARM_TENANT_ID="ce97b324-87be-4ec9-9fcc-cbc7b9289bed"
      ARM_SUBSCRIPTION_ID="268250f7-7cbb-46b4-9ecd-99d5a60ffc76"
      TF_VAR_provisioner_arm_client_secret="${ARM_CLIENT_SECRET}"
      ```

## Usage

Deploy:
```
terraform apply
```
Destroy:
```
terraform destroy
```