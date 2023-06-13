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
5) Update *terraform.tf* provider config:
   - *credentials* key (path to json file)
   - *project* key (project name)

## Usage

Deploy:
```
terraform apply
```
Destroy:
```
terraform destroy
```
