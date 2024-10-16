# Infrastructure-as-code(IAC)
Infrastructure as Code (IaC) tools allow you to manage infrastructure using configuration files rather than through a graphical user interface/Command line interface/Api. Most of cloud provider has own infrastructure as code machanism. Following are the example list
1. Iac tool for AWS is CloudFormation template
2. Iac tool for azure is Azure Resource Manager
3. Iac tool for Openstack is Head teamplate
4. Iac tool for GCP is Google Cloud Deployment Manager

# Why terraform 
We can manage multiple cloud platform using single Iac tool called terraform. we don't need individual cloud iac tool.
Competitor for terraform called `pulumi`/crossplane

# Install terraform 
check installation guide : https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli.<br />
Verfify installation : `terraform version`
For help : `terraform -help/terraform`

# HCL 
HCL (HashiCorp Configuration Language) is a declarative language(define "what" you want . don't need how) used in Terraform to define infrastructure configurations.HCL files typically have a .tf extension

1. Block : blocks is define everyting in hcl .Blocks have a `type` that can have `zero or more required labels` followed by `{ }` brackets that contain the block's body. Blocks can be nested inside each other.The basic structure of a block is as follows:
```
block_type "label_1" "label_2" {
  parameter = value
  nested_block {
    parameter = value
  }
}
```

# Terraform Block
The terraform  block contains Terraform settings. for example
1. `required_version`. Defines the Terraform version requirements
3. `backend block`: discuss later.
2. required providers
    ```
    <local_name> = {
      source  = "<source_address>"
      version = "version"
    }
    ```

    i.`local_name` . its unique identifier within this module(module-specific). every provider has a preferred local name(we recommend using a provider's preferred local name, which is usually the same as the "type" portion of its source address), which it uses as a prefix for all of its resource types. (For example, resources from hashicorp/aws all begin with aws, like aws_instance or aws_security_group.)

    *** it's sometimes necessary to use two providers with the same preferred local name in the same module, usually when the providers are named after a generic infrastructure type. Terraform requires unique local names for each provider in a module, so you'll need to use a non-preferred name for at least one of them.



    ii.`source` . A provider's source address is its global identifier. Examples of valid provider source address formats include: HOSTNAME/NAMESPACE/TYPE

    ** `HOSTNAME` (optional): The hostname of the Terraform registry that distributes the provider. If omitted, this defaults to registry.terraform.io, the hostname of the public Terraform Registry.

    ** `NAMESPACE`: An organizational namespace within the specified registry. For the public Terraform Registry(registry.terraform.io) and for HCP Terraform's private registry, this represents the organization that publishes the provider. This field may have other meanings for other registry hosts.

    ** `Type`: A short name for the platform or system the provider manages. Must be unique within a particular namespace on a particular registry host.

    iii. `version` define source version (Optional) . default recent version

# Provider Block
configures the specified provider

```
provider "<local_name>" {
  parameter = value
}
```

For aws : 
1. `region`: Defines the AWS region to work in
2. `profile` : if you don't want to use aws cli `default` profile then override it . if dont want to use profile you can directly use access key and key(not recommendate)<br />
   `access_key` = "your-aws-access-key"<br />
   `secret_key` = "your-aws-secret-key"<br />
3. `alias` : Allow to create multiple configurations for the same provider .It is used at `resource` block . check it there
4. `version`:  which we no longer recommend depricated (use provider requirements instead)   

For google : 

```
provider "google" {
  project = "my-gcp-project"
  region  = "us-central1"
  credentials = file("path-to-credentials.json")
}
```

For Azure

```
provider "azurerm" {
  features {}
}
```

# Resource Block
Define components of your infrastructure. A resource might be a physical or virtual component such as an EC2 instance, or it can be a logical resource such as a Heroku application.

```
resource "<resource_type>" "resource_name" {
  parameter = value
}
```

The prefix of the type maps to the name of the provider.For example, an `aws_instance` resource uses the default `aws` provider configuration
Together, the resource type and resource name form a unique `ID` for the resource
1.Resource Arguments : check documentation which arguments are available . [Link](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

2. Meta-arguments
  i. `provider` : specify your provider by the form `<PROVIDER NAME>.<ALIAS> `. if no specify then it use default provider (which one is no `alias` property). Documentation link [Link](https://developer.hashicorp.com/terraform/language/resources/syntax)


# Life cycle of terraform
1. `terraform init` : Initializing a configuration directory downloads and installs the providers defined in the configuration. Its `mandatory` for first time
2. `terraform fmt` : Automatically updates/format(fmt) configurations in the current directory for readability and consistency.
3. `terraform validate`: Make sure your configuration is syntactically valid and internally consistent
4. `terraform plan`: to preview the changes that will be made to your infrastructure
5. `terraform apply`: Apply the configuration to your infrastructure. its `mandatory`
6. `terraform show` : After apply, Terraform wrote data into a file called `terraform.tfstate`. It track which resources it manages so that it can update or destroy those resources going forward and often contains sensitive information,so you must store your state file securely. This command inspect/show the current state without to go provider UI. 
  For storing state file remotely you can use following 
  1. `HCP Terraform/ Terraform enterprise`. It is recommendate . https://developer.hashicorp.com/terraform/tutorials/cloud/cloud-migrate
  2. `Third party backend remote` : 
  https://developer.hashicorp.com/terraform/language/backend/configuration
7.`terraform state` : for advanced state management .for example `terraform state list` list the resource of your project.  


# Create first terraform project

It will create single ec2 instance. Create `newfolder->main.tf` then add following content

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ca-central-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-00498a47f0a5d4232"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

```

1. `AMI(Amazon machine image)` : check list aws console->ec2->Images->AMI
2. `instance_type`: Define instance type
3. `count`: Define how many resource you need

  Aws instance doc
  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

For Execution use `mandatory` command  

# Variable Block
There are 3 types of variable
1. Input variable : allow  to pass values into your configuration file from the outside

```
variable "variable_name"{
  description = "Description here "
  type = "Datatype of variable"
  default = "default value if you provided"
  sensitive = true #disable to show in logs or output
}
```


1. `string` :	Single string value
2. `number`:	Numeric value (integer or floating point)
3. `bool`	Boolean value (true or false)
4. `list(<type>)`	Ordered list of values of the same type
```
variable "example_list" {
  type    = list(string)
  default = ["apple", "banana", "cherry"]
}
```
5. `set(<type>)`	Similar to `List` Unordered, unique collection of values of the same type
5. `map(<type>)`	Key-value pairs, where all values are the same type
```
variable "example_map" {
  type = map(string)
  default = {
    key1 = "value1"
    key2 = "value2"
  }
}
```
6. `object({ <attr>: <type> })`	Structured collection of named attributes, each with a defined type
```
variable "example_object" {
  type = object({
    name   = string
    age    = number
    active = bool
  })
  default = {
    name   = "John"
    age    = 30
    active = true
  }
}
```
7. `tuple([<type>, ...])`	similar to `list` but each element can be a different type

```
variable "example_tuple" {
  type = tuple([string, number, bool])
  default = ["apple", 10, true]
}
```

8. `any`	Can accept any type of value
9. Complex data type 
```
variable "list_of_objects" {
  type = list(object({
    name = string
    age  = number
  }))
  default = [
    {
      name = "Alice"
      age  = 25
    },
    {
      name = "Bob"
      age  = 30
    }
  ]
}
```

```
variable "map_of_lists" {
  type = map(list(string))
  default = {
    group1 = ["value1", "value2"]
    group2 = ["value3", "value4"]
  }
}
```

Usage : `var`.<variable_name> . if within strings `"tes-${us usual}"`

Variable can be a file called something ./variables.tf or `main.tf` with following

```
variable "instance_type" {
  description = "Value of the EC2 instance type"
  type        = string
  default     = "t2.micro"
}
```
Update `main.tf` : "t2.micro" -> var.instance_type

Override variables from outside by following way
1. Command-line Flags : `terraform apply -var="variable_name=value"`
2. Environment Variables : `export TF_VAR_variableName=value`
3. Using `.tfvars` : by default it search `terraform.tfvars`/`file_name.auto.tfvars` . 
<br />if your different file name then use `terraform apply -var-file="custom_override.tfvars"`
<br />

`.tfvars` look likes 
```
variable_name = value
```

Precedence : `cli argument -> env. variable->.tfvars file` <br />

Validate variables : <br />

```
variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {
    project     = "my-project",
    environment = "dev"
  }

  validation {
    condition     = length(var.resource_tags["project"]) <= 16 && length(regexall("[^a-zA-Z0-9-]", var.resource_tags["project"])) == 0
    error_message = "The project tag must be no more than 16 characters, and only contain letters, numbers, and hyphens."
  }

  validation {
    condition     = length(var.resource_tags["environment"]) <= 8 && length(regexall("[^a-zA-Z0-9-]", var.resource_tags["environment"])) == 0
    error_message = "The environment tag must be no more than 8 characters, and only contain letters, numbers, and hyphens."
  }
}
```
2. Local variable : Reduce duplication in your code. Add local variable configuration file(`main.tf`)
```
locals {
  variable_name = value
}
```
Usage : same as before

2. Output variable : used to display values from your Terraform configuration after the `apply` command
```
output "variable_name"{
  description = "Description here "
  value = "expression"
}
```
Expression : `resource_all_level_by_dot.resource_property` . in case module output variable prefix `module.module_name.` <br />

To show output variable after `apply` command . use the following command<br />
  i. `terraform output` : show all output variable 
  ii. `terraform output variable_name` : show single output variable 
  iii. `terraform output --json` : show all output variable with json format

# Conditional expression

Add a variable at `variables.tf`

```
variable "is_create_instance" {
  description = "Create instance flag"
  type        = bool
}
```

Add new property  `count` on resource at `main.tf` <br />

`count         = var.is_create_instance ? 1 : 0` <br />

When run `terraform plan/apply` then ask you enter is_create_instance variable value

# Terrafrom module 
Modules are the main way to package and `reuse` resource configurations with Terraform.
<br/>
In the structure:<br />
`Root module`: The main.tf in the root folder contains the top-level configurations.<br/>
`Submodule`: The modules/<module_name> folder contains the reusable confirguation.

From `Root module`  calls other modules by following syntax

```
module "<module_name>"{
  source ="<path for submodule main.tf>"
  version = 
}
```
1. `version` : it is recommended for modules from a `registry/git repo` for consistance all environment since it is loaded latest version when use `terrafrom init` on different env..
2. `Providers` : same as before

 Move `main.tf` content to `module->aws_instance->main.tf` to create `submodule` <br />
 update main.tf with following content
```
module "ec2" {
  source = "./module/aws_instance"
}
````

# Meta arguemnt : Availble for resource and module( technically it is resource)
1. `count` : same as before
2. `for_each` : Similar to `count`, but allows for more complex iteration over a `map` or `set of strings`

Note : for_each, each instance is addressed as part of a map, not as a list, so you can’t use [*] to access all instances. instead <br >
`[for instance in aws_instance.app_server : instance.id]` as output variable

```
for_each = toset(["Server1", "Server2"])
  tags = {
    Name = each.value #each.value is same as each.key
  }
```

```
for_each = tomap({
    "instance1" = {
      ami           = "ami-00498a47f0a5d4232"
      instance_type = "t2.large"
    }
    "instance2" = {
      ami           = "ami-00498a47f0a5d4232"
      instance_type = "t2.large"
    }
  })

  ami           = each.value.ami           # Accessing the AMI from the current value
  instance_type = each.value.instance_type # Accessing the instance type from the current value

  tags = {
    Name = each.key  # Using each.key to name the instances (instance1, instance2)
  }
```
3. `depends_on` : teraform automatically infer them implicity `depends_on` if there relation between resources . for example

```
resource "aws_security_group" "my_sg" {
  name = "my-security-group"
}

resource "aws_instance" "my_instance" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_sg.id]
}
```

In this "aws_instance" resource reference "aws_security_group" resource thats means it is depend on . then it will dependant resource first. 

If there are no such relationship but if you want to dependent use `depends_on` field 

```
# Create an S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-example-bucket-123456"
}

# Create an IAM policy that depends on the S3 bucket
resource "aws_iam_policy" "my_policy" {
  name        = "MyPolicy"
  description = "My IAM policy that uses an S3 bucket"

  # Policy document allowing access to the S3 bucket
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:ListBucket"
        Effect   = "Allow"
        Resource = aws_s3_bucket.my_bucket.arn
      }
    ]
  })

  # Ensure the IAM policy is created only after the S3 bucket is created
  depends_on = [aws_s3_bucket.my_bucket]
}

# Attach the IAM policy to a user
resource "aws_iam_user_policy_attachment" "attach_policy" {
  user       = "example-user"  # Replace with your actual user
  policy_arn = aws_iam_policy.my_policy.arn

  # Ensure the attachment occurs only after the IAM policy is created
  depends_on = [aws_iam_policy.my_policy]
}
```
4. `lifecyle` : Syntax 
```
  lifecycle {
    <property> = value
  }
  ```
1. `create_before_destroy` : By default  terraform destroy the existing object and then create a new replacement object . you can alter this behaviour by setting flag true
2. `prevent_destroy` : Disallow `terraform destroy` command but if total resource block is missing then it will allow!!!
3. `ignore_changes: (list of attribute names)` : ignore some the attribute changes. eg. [tags,tags["name"],tag[0]]

4.`replace_triggered_by (list of resource or attribute references)` : Replaces the resource when any of the referenced items change
5. `Custom conditions` : you add `precondition` and `postcondition` blocks with a lifecycle to specify assumptions and guarantees about how resources and data sources operate

```
 The AMI ID must refer to an AMI that contains an operating system for the `x86_64` architecture.
    precondition {
      condition     = data.aws_ami.example.architecture == "x86_64"
      error_message = "The selected AMI must be for the x86_64 architecture."
    }
The EC2 instance must be allocated a public DNS hostname.
    postcondition {
      condition     = self.public_dns != ""
      error_message = "EC2 instance must be in a VPC that has public DNS hostnames enabled."
    }    
```

#  Backend block
Terraform uses a backend called `local` by default. The local backend type stores state(`terraform.tfstate`)  as a local file on disk(relative to the root module path) . This can cause issues when multiple team members are working on the same infrastructure, leading to conflicts or state corruption due to locally store for each member + it can some sensitive data like access key etc. To solve this, Terraform allows you to store your state file in remote locations, like AWS S3, HashiCorp Terraform Cloud, Azure Blob Storage, and more.

```
backend "backend_name" {
    //configuration
  }
```
1. Remote Backend with AWS S3 : 
```terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate" # Path to the state file in the bucket
    region         = "us-west-2"
    dynamodb_table = "your-dynamodb-table" 
    encrypt        = true                    # Encrypt the state at rest
  }
}
```
Terraform need the following IAM permission <br>
`s3:ListBucket`<br>
`s3:GetObject`<br>
`s3:PutObject`<br>
`dynamodb:DescribeTable`<br>
`dynamodb:GetItem`<br>
`dynamodb:PutItem`<br>
`dynamodb:DeleteItem`<br>

`dynamodb_table` :   Enables state locking so that it prevents concurrent access issues when multiple users or processes run Terraform. aws dynamodb create table comma 
`aws dynamodb create-table --table-name your-dynamodb-table --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
`<br />
`cat .terraform/terraform.tfstate` : check existing backend if have
`terraform init -migrate-state` :Any change on backend's configuration, you must run it.
`Partial configuration` : you can empty or partial configuration . variable can allow here
```
terraform {
  backend "s3" {}
}
```
There are several ways to supply the remaining arguments:
  1. `Using File` : create file called something `<any name>.hcl` with following content 
  ```
  bucket         = "your-terraform-state-bucket"
  key            = "terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "your-dynamodb-table"
  ```
  usage : `terraform init -backend-config=backend.hcl`
  2. `Using cli argument` : 
  ```
  terraform init \
  -backend-config="KEY=VALUE" \
  -backend-config="KEY=VALUE

  ```
  3. `Interactively`: Terraform will interactively ask you for the required values <br />

  Note : here allow variable reference but does not allow resource reference since backend configure before resource create <br > <br > 
2. Remote Backend with Terraform Cloud : It provides some features like remote execution, version control, collaboration tools, and a centralized workspace.
```
backend "remote" {
    hostname     = "app.terraform.io"
    organization = "my-organization"

    workspaces {
      name = "my-workspace"
    }
  }
```

`workspaces` : discuss later

`remote execution` : when commands (eg. `plan`, `apply`) run then it is run `Terraform Cloud’s environment` rather than on your local machine and show you output on local in this way it ensuring consistency, security, and compliance

# Workspace
It allow to manage separate state files for different environments without needing to duplicate your configuration. By default terraform have only one workspace (called `default`) that means it works only one environment . but sometime we need multiple workspace(dev,stag,prod) of a single/same configuration. we can add multiple workspace 
1. `terraform workspace show` : show current workspace . to reference the current workspace inside your Terraform code use `${terraform.workspace}`
2. `terraform workspace show` : show list of workspace. here `*` means current workspace  
3. `terraform workspace new <workspace_name>` : create new workpace . it will create new folder on ./terraform.tfstate.d/<workspace_name>
4. `terraform workspace select <workspace_name>` : change current workspace
5. `terraform workspace delete <workspace_name>` : delete workspace

The persistent state stored depend on  `backend` configure

1. `local backend` : `terraform workspace new dev` create new directory on ./terraform.tfstate.d/dev to store state file
2. `s3 backend` : 
```
backend "s3" {
    -----
    key            = "prod/terraform.tfstate" # Path to the state file in the bucket
    workspace_key_prefix = "" #discuss here
    ----
  }
```
`default` workspace state file : stored at `key` path define (above).
`other` workspace state file : stored using the path `<workspace_key_prefix>/<workspace_name>/<key>` . The default value for `workspace_key_prefix` is `env:`(override by `workspace_key_prefix` property)

In case you have multipe workspace terraform need the following s3 IAM permission<br>
`s3:DeleteObject`<br>
3. `remote backend` : 

1. `single workspace` : Current terrafrom remote backend does't support `default` workspace. you must create new workspace and use it by following way 
  ```
  backend "remote" {
      ------
      workspaces {
        name = "my-workspace"
      }
      ------
    }
  ```
2. `Multiple workspace` :   For multiple workspace. you have to mention `prefix` then tarraform will create remote workspace by `prefix-<workspace_name>` name
```
  backend "remote" {
      ------
      workspaces {
        prefix = "env-"
      }
      ------
    }
  ```


