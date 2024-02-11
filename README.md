## Project name
Terraform resources

## Table of contents
- [Project name](#project-name)
- [Table of contents](#table-of-contents)
- [General info](#general-info)
- [Technologies](#technologies)
- [Setup](#setup)
  - [Terraform examples](#terraform-examples)
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
      or update *terraform.tf* provider config according to documentation: 

## Usage

Deploy:
```
terraform apply
```
Destroy:
```
terraform destroy
```
