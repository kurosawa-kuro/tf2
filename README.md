# tf2

```
terraform init
terraform validate
terraform apply -auto-approve
terraform output -raw private_key > deployer-key.pem
chmod 600 deployer-key.pem
terraform destroy -auto-approve
```
