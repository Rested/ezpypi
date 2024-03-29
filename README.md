# ezpypi - An easy to setup pypiserver

Uses Terraform to provision a digital ocean droplet running a persistent [pypiserver](https://github.com/pypiserver/pypiserver) via nginx complete with caching, and backups.

Predicted cost: $6/month

### Pre-requisits

You will need a digital ocean account, complete with an api key.

### Steps
Setup the basics
```bash
cp .env.sample .env
# Now change the values to what you want
eval `ssh-agent` # to ensure ssh-agent is running
ssh-keygen # not necessary if you already have a passwordless ssh key
ssh-add /path/to/generated/sshkey
# ensure that the public_key in main.tf is pointing to this key
```
Now set up your password for the server
```bash
htpasswd -sc htpasswd.txt <your-name>
# enter the password you want to use to log in to your pypi with.
```
See https://github.com/pypiserver/pypiserver#upload-with-setuptools for usage of your new username and password.

Run terraform
```bash
export $(grep -v '^#' .env | xargs -d '\n')
terraform init # get providers installed
terraform plan # check everything seems reasonable
terraform apply # get it up in the cloud!
```
### Uploading packages

For uploading you will want to make sure your `~/.pypirc` looks something like
```
[distutils]
index-servers =
  pypi
  ezpypi

[pypi]
username: username
password: password


[ezpypi]
repository: http://hostname/
username: yourname
password: yourpassword
```

Then you can upload with 
```bash
python setup.py sdist upload -r ezpypi
```
For more secure uploading see: https://github.com/pypiserver/pypiserver#upload-with-twine


### Downloading packages

You can do the more temporary:
```bash
export PIP_EXTRA_INDEX_URL=http://hostname/simple/
```
or the more permanent
```
# ~/.pip/pip.conf
[global]
extra-index-url = http://hostname/simple/
```

With either of these, to avoid putting your username and password in each time (for example in a ci situation), you can use basic http auth:
```
http://yourname:password@hostname/simple/
```


## Todos:
 * HTTPS https://www.terraform.io/docs/providers/acme/index.html + https://github.com/pypiserver/pypiserver#supporting-https
