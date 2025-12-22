# RDS Database Tier - Multi-AZ MySQL
# Provides the data layer for the 3-tier architecture

# Database security group
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group for RDS database"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

# RDS DB Subnet Group for multi-AZ deployment
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# RDS MySQL Instance
resource "aws_db_instance" "main" {
  identifier     = "${var.project_name}-db"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.db_instance_class
  
  allocated_storage    = var.db_allocated_storage
  storage_encrypted    = true
  storage_type         = "gp2"
  
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  multi_az            = true
  publicly_accessible = false
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  skip_final_snapshot = false
  final_snapshot_identifier = "${var.project_name}-db-final-snapshot"
  
  tags = {
    Name = "${var.project_name}-mysql-db"
  }
}

# RDS Read Replica for scalability (optional)
resource "aws_db_instance" "read_replica" {
  count                    = var.enable_read_replica ? 1 : 0
  identifier               = "${var.project_name}-db-read-replica"
  replicate_source_db      = aws_db_instance.main.identifier
  instance_class           = var.db_instance_class
  publicly_accessible      = false
  auto_minor_version_upgrade = true
  
  tags = {
    Name = "${var.project_name}-db-read-replica"
  }
}
