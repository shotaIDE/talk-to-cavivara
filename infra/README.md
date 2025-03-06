Install Terraform.

https://developer.hashicorp.com/terraform/install

Install Google Cloud CLI.

https://cloud.google.com/sdk/docs/install-sdk?hl=ja

Install dependencies.

```shell
terraform init -backend-config=dev.tfbackend
```

Plan.

```shell
terraform plan -var-file=dev.tfvars
```

Apply.

```shell
terraform apply -var-file=dev.tfvars
```

## Development

### Launch Firebase emulator

```shell
firebase use default
firebase emulators:start --import=./emulator-data --export-on-exit=./emulator-data
```
