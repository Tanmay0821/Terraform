--  cd .\terraform\

    To initialize the Dev environment using the Dev state file:

-- terraform init

For Terraform Plan / Apply:

Prod environment:

 --terraform plan -var-file="prod.tfvars" 
 --terraform apply -var-file="prod.tfvars"

Dev environment:

 --terraform plan -var-file="dev.tfvars" 
 --terraform apply -var-file="dev.tfvars"
