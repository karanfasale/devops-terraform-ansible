resource "local_file" "inventory" {
  content = <<EOT
[web]
%{ for ip in aws_instance.web[*].public_ip ~}
${ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/mykey.pem
%{ endfor ~}
EOT

  filename = "${path.module}/../ansible/inventory/inventory.ini"  # ← Use path.module
}

resource "null_resource" "run_ansible" {

  provisioner "local-exec" {
    # Use absolute path from current working directory
    command = "cd ${path.module}/../ && ansible-playbook -i ansible/inventory/inventory.ini ansible/playbooks/install_apache_php.yml"
  }

  depends_on = [
    aws_instance.web,
    local_file.inventory
  ]
}
