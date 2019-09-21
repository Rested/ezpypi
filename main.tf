variable "do_token" {}
variable "hostname" {} // where you want the server to point to

resource "digitalocean_ssh_key" "default" {
  name       = "SSH key"
  public_key = "${file("~/.ssh/id_rsa_no_pass.pub")}"
}

provider "digitalocean" {
  token = "${var.do_token}"
}


resource "digitalocean_droplet" "ezpypi" {
  image = "docker-18-04"
  name = "ezpypi"
  region = "lon1"
  size = "512mb"
  ssh_keys = ["${digitalocean_ssh_key.default.fingerprint}"]
  provisioner "remote-exec" {
    inline = [
      "docker run -d -p 80:8080 pypiserver/pypiserver:latest"
    ]

    connection {
      type     = "ssh"
      user     = "root"
      host     = "${digitalocean_droplet.ezpypi.ipv4_address}"
      agent = true
    }
  }
}

# Create a new domain record
resource "digitalocean_domain" "ezpypi" {
  name = "${var.hostname}"
  ip_address = "${digitalocean_droplet.ezpypi.ipv4_address}"
}

resource "digitalocean_record" "wildcard" {
  domain = "${digitalocean_domain.ezpypi.name}"
  type = "CNAME"
  name = "*"
  value = "@"
}