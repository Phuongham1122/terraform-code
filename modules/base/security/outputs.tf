output "alb_security_group_id" {
    value = aws_security_group.alb_security_group.id
}

output "ec2_security_group_id" {
    value = aws_security_group.ec2_security_group.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds_cluster_security_group.id
}