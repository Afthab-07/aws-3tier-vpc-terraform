# Application Load Balancer and Auto Scaling Setup Guide

## Application Load Balancer (ALB) Configuration

### Create Application Load Balancer

1. **Navigate to EC2 Dashboard**
   - Services → EC2 → Load Balancers
   - Click "Create load balancer"
   - Select "Application Load Balancer"

2. **Configure ALB**
   - Name: `prod-alb`
   - Scheme: Internet-facing
   - IP address type: IPv4
   - VPC: Select your VPC
   - Subnets: Select both public subnets (public-subnet-az1, public-subnet-az2)
   - Security groups: Select ALB security group
   - Click "Next"

3. **Configure Listeners**
   - Protocol: HTTP
   - Port: 80
   - Default actions: Forward to target group
   - Target group: Create new target group (see below)
   - Click "Create"

### Create Target Group

1. **Target Group Configuration**
   - Name: `prod-tg`
   - Protocol: HTTP
   - Port: 80 (or your application port)
   - VPC: Select your VPC
   - Health check protocol: HTTP
   - Health check path: `/` (or your health check endpoint)
   - Health check port: 80
   - Healthy threshold: 2
   - Unhealthy threshold: 2
   - Timeout: 5 seconds
   - Interval: 30 seconds
   - Click "Create"

2. **Register Targets** (After Auto Scaling is set up, instances will register automatically)

## Auto Scaling Group (ASG) Configuration

### Create Launch Template

1. **Navigate to EC2 Dashboard**
   - EC2 → Launch Templates → Create launch template

2. **Configure Launch Template**
   - Name: `prod-launch-template`
   - AMI: Select Amazon Linux 2 or Ubuntu (your choice)
   - Instance type: t3.medium (adjust based on requirements)
   - Key pair: Select or create a key pair for SSH access
   - Security groups: Select EC2 security group
   - User data: (See scripts/user-data.sh for application setup)
   - Storage: 20 GB gp2
   - Click "Create"

### Create Auto Scaling Group

1. **Navigate to EC2 Dashboard**
   - EC2 → Auto Scaling Groups → Create Auto Scaling group

2. **Choose Launch Template**
   - Name: `prod-asg`
   - Launch template: Select `prod-launch-template`
   - Click "Next"

3. **Configure Group Size and Network**
   - Min size: 2
   - Desired capacity: 2
   - Max size: 6
   - VPC: Select your VPC
   - Subnets: Select both private subnets (private-subnet-az1, private-subnet-az2)
   - Click "Next"

4. **Configure Load Balancing**
   - Load balancing: Attach to an existing load balancer
   - Choose target group: Select `prod-tg`
   - Health check type: ELB
   - Health check grace period: 300 seconds
   - Click "Next"

5. **Configure Scaling Policies**
   - Policy name: `scale-up-policy`
   - Policy type: Target tracking scaling
   - Metric type: Average CPU Utilization
   - Target value: 70%
   - Warm-up period: 300 seconds
   - Click "Add scaling policy"

6. **Add Scale Down Policy** (Optional)
   - Policy name: `scale-down-policy`
   - Metric type: Average CPU Utilization
   - Target value: 30%
   - Click "Add scaling policy"

7. **Review and Create**
   - Click "Create Auto Scaling group"

## ALB and ASG Configuration Summary

### Architecture Benefits

1. **Load Distribution**
   - Traffic distributed across multiple instances
   - Multi-AZ deployment for redundancy
   - Automatic health checks ensure only healthy instances receive traffic

2. **Automatic Scaling**
   - Scales up when CPU > 70%
   - Scales down when CPU < 30%
   - Maintains minimum 2 instances for high availability
   - Supports up to 6 instances during peak loads

3. **Self-Healing**
   - Unhealthy instances automatically terminated
   - Replaced by new instances from ASG
   - Zero-downtime deployments possible

## Monitoring and Verification

### Check ALB Health
1. EC2 → Load Balancers
2. Select your ALB
3. Check DNS name: Use this to access your application
4. Monitor target group health status

### Check ASG Activity
1. EC2 → Auto Scaling Groups
2. Select your ASG
3. Monitor Instance Management tab
4. Check Activity history for scaling events

### Test Load Balancing
1. Note ALB DNS name
2. Access application via DNS name multiple times
3. Verify traffic distributed across instances
4. Check CloudWatch metrics

## Cost Optimization

1. **Right-sizing Instances**
   - Monitor CPU and memory usage
   - Adjust instance type if consistently underutilized
   - Use t3 burstable instances for variable workloads

2. **Scaling Policies**
   - Set appropriate min/max limits
   - Scale down aggressively during off-peak hours
   - Use scheduled scaling for predictable traffic patterns

3. **ALB Configuration**
   - ALB charges per LCU (Load Balancer Capacity Unit)
   - Monitor and optimize target registration count
