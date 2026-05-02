output "instance_public_ip" {
  description = "IP publique de l'instance EC2"
  value       = aws_instance.hotel.public_ip
}

output "instance_public_dns" {
  description = "DNS public de l'instance"
  value       = aws_instance.hotel.public_dns
}

output "website_url" {
  description = "URL du site hôtel"
  value       = "http://${aws_instance.hotel.public_ip}"
}

output "ssh_command" {
  description = "Commande SSH pour se connecter"
  value       = "ssh -i hotel-key.pem ec2-user@${aws_instance.hotel.public_ip}"
}

output "ebs_volume_id" {
  description = "ID du volume EBS data"
  value       = aws_ebs_volume.data.id
}

output "snapshot_id" {
  description = "ID du snapshot"
  value       = aws_ebs_snapshot.root_snapshot.id
}

output "custom_ami_id" {
  description = "ID de l'AMI personnalisée"
  value       = aws_ami.hotel_ami.id
}