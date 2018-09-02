## **Wordpress-deployment**

Terraform sets up an AWS EC2 instance, sets up your key pair based on an imported public key (key.kp), and connects with a specified private key.
Then Ansible sets up the rest of the server, installing the dependencies and wordpress.
It gives you an elastic IP that is globally accessible with HTTP so you can instantly see your deployment after the steps run.

## Requirements

  - Ansible
  - Terraform
  - public and private keys
  - amazon AWS keys
  - terraform.tfvars file setup


## Instructions

After importing and setting up terraform in your path (or specifying the path manually )
run

terraform init
terraform plan
terraform build

That should be it. Then simply browse to the IP address output to see your new wordpress installation

## Later versions
 Will demonstrate database and file persistence
 Will separate the web, DB, and front end tier (ELB)
 To include AWS monitoring setup with terraform 
