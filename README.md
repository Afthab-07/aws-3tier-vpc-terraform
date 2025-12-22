# AWS VPC Infrastructure

## Overview

A highly available AWS network architecture with multi-AZ VPC, ALB, Auto Scaling, Bastion Host, Security Groups, NACLs, and CloudWatch monitoring.

This project demonstrates how to build secure and scalable cloud infrastructure using Terraform.

## Architecture

- **VPC**: Network container across 2 Availability Zones
- **Subnets**: Public and private subnets for high availability
- **ALB**: Application Load Balancer for traffic distribution
- **EC2**: Auto Scaling Group for scalable web servers
- **Bastion Host**: Secure SSH access to private instances
- **Security**: Security Groups and NACLs for least-privilege access
- **Monitoring**: CloudWatch logs and metrics for observability

## Features

✓ Multi-AZ high availability
✓ Auto Scaling for dynamic load handling
✓ Secure network architecture with private subnets
✓ Bastion host for controlled server access
✓ Real-time monitoring with CloudWatch
✓ Infrastructure as Code using Terraform

## Technologies Used

- **AWS**: VPC, EC2, ALB, Auto Scaling, Security Groups, NACLs, CloudWatch
- **IaC**: Terraform for reproducible infrastructure
- **Networking**: Multi-AZ, subnets, routing, gateways

## Directory Structure

```
├── architecture/
│   └── architecture-description.md
├── scripts/
│   └── user-data.sh
├── setup-guides/
│   └── monitoring-cloudwatch.md
└── README.md
```

## Getting Started

1. Configure AWS credentials
2. Update Terraform variables
3. Run `terraform init` and `terraform apply`
4. Access the load balancer DNS for your web application

## Key Learnings

- Building secure VPC architecture
- Implementing high availability across AZs
- Using Auto Scaling for reliability
- Monitoring infrastructure with CloudWatch
- Writing reusable Terraform code
