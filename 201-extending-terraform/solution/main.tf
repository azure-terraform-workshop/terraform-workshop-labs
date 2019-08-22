resource "random_password" "password" {
  length  = 16
  special = true
  count = 5
}

output "password" {
  value = random_password.password.*.result
}

resource "random_uuid" "guid" {
  keepers = {
    datetime = timestamp()
  }
}

output "guid" {
  value = random_uuid.guid.result
}

resource "tls_private_key" "tls" {
  algorithm = "RSA"
}

output "tls-public" {
  value = tls_private_key.tls.public_key_openssh
}

output "tls-private" {
  value = tls_private_key.tls.private_key_pem
}

resource "local_file" "tls-public" {
  filename = "id_rsa.pub"
  content  = tls_private_key.tls.public_key_openssh
}

resource "local_file" "tls-private" {
  filename = "id_rsa.pem"
  content  = tls_private_key.tls.private_key_pem

  provisioner "local-exec" {
    command = "chmod 600 id_rsa.pem"
  }
}

