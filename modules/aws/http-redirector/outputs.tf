output "httpredirecthost" {
  value = aws_instance.httpredirecthost
}

output "httpredirectprivate-ip" {
  value = concat(aws_instance.httpredirecthost.*.private_ip)
}

output "httpredirectpublic-ip" {
  value = concat(aws_instance.httpredirecthost.*.public_ip)
}