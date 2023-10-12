# terraform-dbp
This repository's purpose is to teach you : 
- what is terraform and to what extent it can be useful for our data team
- how to setup terraform on your computer 
- how to manage an infrastructure (init, apply, change, destroy)
- some best practices about files, input varaibles and outputs


# Prerequisites

You need: 
- Terraform setup on your computer
- A Google Cloud Platform Account 
- A GCP Project where you want to build this example infrastructure (the best is to be multi projects for production purpose)

For granting Terraform to interact with our GCP account, we need to create a service account with Owner rights on the platform. Here it is terraform-infra-380516 account. 

# Setup 

## Install terraform on your computer

On **MacOS**, with homebrew : 

```bash
brew tap hashicorp/tap # install the HashiCorp tap, a repository of all our Homebrew packages.
brew install hashicorp/tap/terraform #Now, install Terraform with hashicorp/tap/terraform
```

On **Windows**, with [chocolately](https://chocolatey.org/install) : 
```
choco install terraform
```

To check everything is fine 

```bash
terraform -v 
```

You can check the commands with help : 
```
terraform -help <command>
```

Source : [Install Terraform](https://developer.hashicorp.com/terraform/downloads)


## Get the repository 

Clone and reach the repository
````
git clone https://github.com/cityscoot/terraform-dbp
cd terraform-dbp
````

Create your own fresh branch and move into it
```
git checkout -b dbp-<name>
```

# Before we begin 

## What is Terraform ? 
Terraform is a tool that allows you to manage infrastructure as code, which means you can use code to define and provision the resources needed for your data platform.

## Why is it useful for a modern data platform ? 

Using Terraform for a modern data platform has several benefits:

- **Consistency** : With Terraform, you can create a standard set of resources that can be easily replicated across different environments, such as development, testing, and production. This ensures consistency in the configuration of your data platform.

- **Automation** : Terraform automates the process of creating and managing resources, which saves time and reduces the likelihood of human error.

- **Flexibility** : Terraform supports a wide range of cloud providers, including AWS, Azure, Google Cloud, and more. This means you can use the same tool across multiple cloud providers, and easily switch between providers as needed.

- **Collaboration** : Since Terraform code is stored in a version control system like Git, it is easy for multiple team members to collaborate on the same codebase. This promotes teamwork and makes it easier to share knowledge.

In summary, Terraform is an excellent tool for managing the infrastructure for a modern data platform. 

It allows you to automate the process of creating and managing resources, ensure consistency across different environments, and collaborate effectively with your team.

# Building a first infrastructure
Terraform loads all files ending in .tf or .tf.json in the working directory. So, we need to create a file main.tf to begin. 

```
vi main.tf
```

We are going to init our work with three blocks : 

- `terraform {}` : contains Terraform settings and especially providers to use when provisionning our infrastructure. It installs providers from [Terraform Registry.](https://registry.terraform.io/)
- `provider {}` : configures the specified container.
- `resource <resource_type> <resource_name>{} :` configures the components of the infrastructure.

## Terraform settings for Google provider 
You can find the all providers on [Terraform Registry](https://registry.terraform.io/browse/providers). First, we setup the Google provider in order to interact with Google Cloud Platform.  
```
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.59.0"
    }
  }
}
```

## Google provider specific configuration
Here we are going to use the terraform-infra service account to manage resources for our existing project [dbp-terraform-infra](https://console.cloud.google.com/welcome?hl=fr&project=dbp-terraform-infra). Note that We would have been able to create the project directly with Terraform. 

```
provider "google" {
  credentials = file("<NAME>.json")

  project = "<PROJECT_ID>"
  region  = "europe-west9"
  zone    = "europe-west9-c"
}
```

## Declare a service account for BigQuery 
We use the resource google_service_account to create the service account bigquery_owner 
```
resource "google_service_account" "bigquery-owner-sa-<name>" {
  account_id   = "bigquery-owner-sa-<name>"
  project      = "dbp-terraform-infra"
  display_name = "service account to manage BigQuery resources"
  description  = "service account to manage BigQuery resources"
}
```


## Initialize the directory

When we create a new configuration, we need to init te directory 

```bash
terraform init 
```

## Format and validate the configuration

```bash
terraform fmt # updates configuration for readability and consistency 
terraform validate # checks itf syntax is valid and consistent
```

## Create infrastructure

```bash
terraform apply 
```

This outputs an execution plan

## Inspect state

When we apply the configuration, a new file pop up `terraform.tfstate` . It stores ids and properties of the resources it manages. 

We can see the state with 

```bash
terraform show
```


# Changes on infrastructure 

We are going to modify the Terraform infrastucture and see in-place and destructive changes. To illustrate this, we are going to instantiate a virtual machine with Compute Engine. 

## Add a new machine with Compute engine

We add a new resource (debian virtual machine here). 

```bash
resource "google_compute_instance" "vm_instance_<name>" {
  name         = "terraform-instance-<name>"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network    = “default”
    subnetwork = “default”
    access_config {
      network_tier = “PREMIUM”
    }
  }
}
```

Arguments `boot_disk` is used : 
all args are under the [Terraform resource description](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance).  

We now apply the changes 

```bash
terraform apply 
```

## Change in-place

Then we add a tag to change the instance in-place 

```bash
resource "google_compute_instance" "vm_instance_<name>" {
  name         = "terraform-instance_<name>"
  machine_type = "e2-micro"
  tags         = ["airflow", "prod"]

 boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network    = “default”
    subnetwork = “default”
    access_config {
      network_tier = “PREMIUM”
    }
  }
}
```

The prefix `~` means that Terraform will update the resource in-place. 

## Destructive change

For example you can change the os :
```
boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }
````
A destructive change is a change that requires the provider to replace the existing resource rather than updating it.

The prefix `-/+` means that Terraform will destroy and recreate the resource, rather than updating it in-place.


# Destroy our infrastructure 

`terraform destroy` command terminates resources managed by your Terraform project.

The `-`prefix indicates that Terraform will destroy the instance and the network.

# Managing variables and secrets 

We declared variables directly in our code and it is not a good practice ! 

Create a file [variables.tf](http://variables.tf) to declare your amazing variables : 

```bash
variable "project" { }

variable "region" { 
   default = "us-central1"
}

variable "zone" { }
```

The `project` and `zone` variables have an empty block: `{ }`. The `region` variable set defaults. If a default value is set, the variable is optional. Otherwise, the variable is required. 

If you run `terraform plan` now, Terraform will prompt you for the values for `project` and `zone`.

Then we need to use these variables in our configuration file. To do it the syntax is var.<var_name>

```bash
provider "google" {
  credentials = file("terraform-infra-380516.json")

  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_service_account" "bigquery-owner-sa" {
  account_id   = "bigquery-owner-sa"
  project      = var.project
  display_name = "service account to manage BigQuery resources"
  description  = "service account to manage BigQuery resources"
}
}
```

You can populate variables using values from a file. Terraform automatically loads files called `terraform.tfvars`

```bash
project = "dbp-terraform-infra"
region  = "europe-west9"
zone    = "europe-west9-c"
```

You can now recreate the environment ! Congrats, your code is more readable ! 



# Let's use variable interpolation by improving IAM policy 

We need to attach IAM policy to our service account. To do this we can to use the resource [google_project_iam_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam#google_project_iam_binding).

To declare the service account email, we use the very powerful variable interpolation. 

```
resource "google_project_iam_binding" "project" {
  project = var.project
  role    = "roles/bigquery.admin"

  members = [
    "serviceAccount:${google_service_account.bigquery-owner-sa.email}",
  ]
}
```

Variable interpolation is a way to reference the value of a variable inside a Terraform configuration. 


We now have a service account with owner grants on BigQuery ! We are going to see how to get the private key attached to this account. 

# Get outputs from Terraform 

Define an output for the private key of your service account that Terraform provisions. First you need to output the key by adding this in your main.tf : 
```
resource "google_service_account_key" "bigquery-owner-sa-key" {
  service_account_id = google_service_account.bigquery-owner-sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}
```

Then, create a file called outputs.tf with the following content:
```
output "bigquery-owner-sa-key" {
  value = google_service_account_key.bigquery-owner-sa-key.private_key
  sensitive = true
}
```
You can now apply and output the result : 
```
terraform apply 
terraform output
```

# Improve your repository architecture 

We now have a lot of code and it is harder and harder to understand the different resources involved. 

In order to have a more readable code repository, I suggest to separate files according to their function : 
-maint.tf 
- service_account.tf
- iam.tf 
- outputs.tf
- variables.tf 
- gce.tf 

With this refactor, here are the files : 

### main.tf 

```
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.59.0"
    }
  }
}

provider "google" {
  credentials = file("terraform-infra-380516.json")

  project = var.project
  region  = var.region
  zone    = var.zone
}
```

### service_account.tf 

```
# BigQuery Owner service account 
resource "google_service_account" "bigquery-owner-sa" {
  account_id   = "bigquery-owner-sa"
  project      = var.project
  display_name = "service account to manage BigQuery resources"
  description  = "service account to manage BigQuery resources"
}

# BigQuery Owner account key
resource "google_service_account_key" "bigquery-owner-sa-key" {
  service_account_id = google_service_account.bigquery-owner-sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}
```

### iam.tf

```
resource "google_project_iam_binding" "project" {
  project = var.project
  role    = "roles/bigquery.admin"

  members = [
    "serviceAccount:${google_service_account.bigquery-owner-sa.email}",
  ]
}
```

### gce.tf 

```
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "e2-micro"
  tags         = ["data", "test"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "default"
    access_config {
    }
  }
}
```

Our architecture is really more understable now ! Congrats ! 

# To infinity and beyond

**It's demo time !** 

We are going to deploy a demo data platform with very promising resources ! Nothing is created manually or pre-existing on the project : *we are really able to destroy everything and then build this working infrastructure here* ! 

## Global Architecture 

![Here is our architecture for the demo ](https://github.com/jeremypayan/terraform-modern-data-stack/blob/main/demo_archi.drawio.png)

Our data source is this [googlesheet](https://docs.google.com/spreadsheets/d/1HzUgtoK_1oXptBj2A8e9Hip96SruI59DhHwq4VVF548/edit?usp=sharing) because we have some network workaround to connect to our relationnal databases far example. For your information, I have done a test with slack as data source as well. 

## Network 

I have created a [VPC](https://console.cloud.google.com/networking/networks/list?hl=fr&organizationId=578528415802&orgonly=true&project=dbp-terraform-infra&supportedpurview=project) and specific [firewall rules](https://console.cloud.google.com/networking/firewalls/list?hl=fr&organizationId=578528415802&orgonly=true&project=dbp-terraform-infra&supportedpurview=project) to manage interactions between all this amazing stuff. When I provision resources, I attach the right network and firewall rules. This is pretty ok for a demo ;) 


## BigQuery datasets and tables 
 
 We create a [dataset](https://console.cloud.google.com/bigquery?hl=fr&organizationId=578528415802&orgonly=true&project=dbp-terraform-infra&supportedpurview=project&ws=!1m4!1m3!3m2!1sdbp-terraform-infra!2sdbp_domain_marketing) called dbp_domain_marketing and a [table](https://console.cloud.google.com/bigquery?hl=fr&organizationId=578528415802&orgonly=true&project=dbp-terraform-infra&supportedpurview=project&ws=!1m4!1m3!3m2!1sdbp-terraform-infra!2sdbp_domain_marketing) (with its description) to receive our data. 


## Ingestion 

For ingestion, I have setup a [Airbyte](https://airbyte.com/) instance for managing various Extract and load processes. This is especially useful for listening a database change data capture so that we can sync remote tables in our warehouse without any codeline ! 

Some interesting connectors : 
- Google sheets 
- MySql
- PostgreSQL 
- Amplitude 
- Kafka 
- BigQuery 
- Confluence 
- facebook 
- Linkedin
- Twitter 
- Freshdesk 
- Cloud Storage 
- Pub/Sub
- Jira 
- SqlServer 
- Notion 
- Stripe 
- Sentry 
- Zendesk 

![Here is our Airbyte instance :tada](https://github.com/jeremypayan/terraform-modern-data-stack/blob/main/images/Capture%20d%E2%80%99%C3%A9cran%202023-03-30%20%C3%A0%2013.55.01.png)

## Transformations 

We use DataForm for transformations. 

## Orchestration 

For orchestration we use Airflow because we know it well and it is great for monitoring purposes ! 



## Visualisation 

We use Cloud Data Studio for visualisation and it works well ;) 

## Catalog and Governance 

We create a central catalog with two tag templates four our tables in datamarts and analytics spaces : 
- Data Product to describe the table characteristics like ownership, documentation links etc. 
- Data Freshness 

![Our tag policy in practice :tada](https://github.com/jeremypayan/terraform-modern-data-stack/blob/main/images/catalog_tags.png)