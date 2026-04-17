resource "local_file" "inventory" {
  content = <<EOT
[web]
%{ for ip in aws_instance.web[*].public_ip ~}
${ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/mykey.pem
%{ endfor ~}
EOT

  filename = "../../ansible/inventory/inventory.ini"
}

resource "null_resource" "run_ansible" {

  provisioner "local-exec" {
    command = "ansible-playbook -i ../../ansible/inventory/inventory.ini ../../ansible/playbooks/install_apache_php.yml"
  }

  depends_on = [
    aws_instance.web,
    local_file.inventory
  ]
}
