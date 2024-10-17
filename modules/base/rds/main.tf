resource "aws_db_subnet_group" "default" {
  name       = "rds-subnet-group"
  subnet_ids = [var.private_data_subnet_az1_id, var.private_data_subnet_az2_id, var.private_data_subnet_az3_id]
}

# resource "aws_rds_cluster_instance" "cluster_instances" {
#   count              = 2
#   identifier         = "aurora-cluster-demo-${count.index}"
#   cluster_identifier = aws_rds_cluster.default.id
#   instance_class     = "db.m5d.large"
#   engine             = aws_rds_cluster.default.engine
#   engine_version     = aws_rds_cluster.default.engine_version
# }

# resource "aws_rds_cluster" "default" {
#   cluster_identifier      = "employee-db-cluster"
#   engine                  = "mysql"
#   engine_version          = "8.0.32"
#   master_username         = "admin"
#   master_password         = "123456789"
#   database_name           = "employee"
# }
resource "aws_rds_cluster" "employee_db" {
  cluster_identifier      = "employee-db-cluster"
  engine                  = "mysql"
  engine_version          = "8.0.32"
  master_username         = "admin"
  master_password         = "123456789"
  database_name           = "employee"
  db_cluster_instance_class = "db.m5d.large"
  storage_type              = "gp3"
  allocated_storage       = 20
  backup_retention_period = 5 
  preferred_backup_window = "07:00-09:00"
  db_subnet_group_name    = aws_db_subnet_group.default.name
  skip_final_snapshot = true
  vpc_security_group_ids  = [var.rds_cluster_security_group_id] # Security group ID phù hợp
}

# resource "aws_rds_cluster_instance" "instance" {
#   count                = 2 # Tạo hai instance cho cluster
#   identifier           = "employee-db-instance-${count.index}"
#   cluster_identifier   = aws_rds_cluster.employee_db.id
#   instance_class       = "db.m5d.large"
#   engine               = aws_rds_cluster.employee_db.engine
#   db_subnet_group_name = aws_db_subnet_group.default.name
#   publicly_accessible  = true # Đảm bảo private
# }