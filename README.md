# Ezpypi

## An easy to install pypi server

Steps:
```bash
cp .env.sample .env
# Now change the values to what you want
eval `ssh-agent` # to ensure ssh-agent is running
ssh-keygen # not necessary if you already have a passwordless ssh key
ssh-add /path/to/generated/sshkey
# ensure that the public_key in main.tf is pointing to this key
export $(grep -v '^#' .env | xargs -d '\n')
terraform init # get providers installed
terraform plan # check everything seems reasonable
terraform apply # get it up in the cloud!
```