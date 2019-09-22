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
  image    = "docker-18-04"
  name     = "ezpypi"
  region   = "lon1"
  size     = "512mb"
  backups  = true
  ssh_keys = ["${digitalocean_ssh_key.default.fingerprint}"]

  provisioner "remote-exec" {
    inline = [
      "mkdir /ezpypi"
    ]

    connection {
      host  = "${digitalocean_droplet.ezpypi.ipv4_address}"
      agent = true
    }
  }
  provisioner "file" {
    source      = "./htpasswd.txt"
    destination = "/ezpypi/htpasswd.txt"
    connection {
      host  = "${digitalocean_droplet.ezpypi.ipv4_address}"
      agent = true
    }
  }

  provisioner "file" {
    source      = "./docker-compose.yml"
    destination = "/ezpypi/docker-compose.yml"
    connection {
      host  = "${digitalocean_droplet.ezpypi.ipv4_address}"
      agent = true
    }
  }

  provisioner "file" {
    source      = "./nginx.conf"
    destination = "/ezpypi/nginx.conf"
    connection {
      host  = "${digitalocean_droplet.ezpypi.ipv4_address}"
      agent = true
    }
  }

  provisioner "file" {
    source      = "./ezpypi.service"
    destination = "/etc/systemd/system/ezpypi.service"
    connection {
      host  = "${digitalocean_droplet.ezpypi.ipv4_address}"
      agent = true
    }
  }
  provisioner "remote-exec" {
    inline = [
      "systemctl enable ezpypi && systemctl start ezpypi"
    ]

    connection {
      host  = "${digitalocean_droplet.ezpypi.ipv4_address}"
      agent = true
    }
  }
}

# Create a new domain record
resource "digitalocean_domain" "ezpypi" {
  name       = "${var.hostname}"
  ip_address = "${digitalocean_droplet.ezpypi.ipv4_address}"
}

resource "digitalocean_record" "wildcard" {
  domain = "${digitalocean_domain.ezpypi.name}"
  type   = "CNAME"
  name   = "*"
  value  = "@"
}