data "template_file" "init" {
  template = file("${path.module}/custom-data.sh.tpl")
  vars = {
    user   = var.username
    width  = 800
    height = 800
  }
}

resource "local_file" "init" {
  filename = ".terraform/custom-data.sh"
  content  = data.template_file.init.rendered
}
