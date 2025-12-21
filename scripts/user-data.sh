#!/bin/bash
# User Data Script for AWS EC2 Instances
# This script runs when EC2 instances are launched
# Purpose: Configure web server and monitoring agent

set -e
echo "Starting EC2 instance setup..."

# Update system packages
sudo apt update -y

# Install web server (Apache HTTP Server)
sudo apt install -y httpd

# Enable Apache to start on boot
sudo systemctl enable httpd

# Start Apache service
sudo systemctl start httpd

# Create a simple health check page
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>AWS Highly Available Architecture</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .success { color: green; font-size: 18px; }
        .info { color: #333; line-height: 1.6; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Welcome to AWS Highly Available Architecture!</h1>
        <p class="success">✓ Web Server is Running</p>
        <div class="info">
            <h2>Architecture Components:</h2>
            <ul>
                <li>Multi-AZ VPC with public and private subnets</li>
                <li>Application Load Balancer for traffic distribution</li>
                <li>Auto Scaling Group for automatic scaling</li>
                <li>CloudWatch monitoring and alarms</li>
                <li>Bastion Host for secure SSH access</li>
                <li>Security Groups and NACLs for network security</li>
            </ul>
            <h2>Instance Information:</h2>
            <p><strong>Hostname:</strong> <span id="hostname"></span></p>
            <p><strong>Instance ID:</strong> <span id="instance-id"></span></p>
            <p><strong>Instance Type:</strong> <span id="instance-type"></span></p>
            <p><strong>Availability Zone:</strong> <span id="availability-zone"></span></p>
            <p><strong>Private IP:</strong> <span id="private-ip"></span></p>
        </div>
    </div>
    <script>
        // Fetch metadata from AWS Metadata Service
        fetch('http://169.254.169.254/latest/meta-data/hostname')
            .then(r => r.text())
            .then(data => document.getElementById('hostname').textContent = data);
        
        fetch('http://169.254.169.254/latest/meta-data/instance-id')
            .then(r => r.text())
            .then(data => document.getElementById('instance-id').textContent = data);
        
        fetch('http://169.254.169.254/latest/meta-data/instance-type')
            .then(r => r.text())
            .then(data => document.getElementById('instance-type').textContent = data);
        
        fetch('http://169.254.169.254/latest/meta-data/placement/availability-zone')
            .then(r => r.text())
            .then(data => document.getElementById('availability-zone').textContent = data);
        
        fetch('http://169.254.169.254/latest/meta-data/local-ipv4')
            .then(r => r.text())
            .then(data => document.getElementById('private-ip').textContent = data);
    </script>
</body>
</html>
EOF

# Create health check page
cat > /var/www/html/health.html << 'EOF'
<html><body><h1>OK</h1></body></html>
EOF

# Optional: Install CloudWatch Agent for detailed monitoring
# Uncomment the following lines if you want CloudWatch Agent installed
#
# wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
# sudo rpm -U ./amazon-cloudwatch-agent.rpm

# Optional: Install AWS Systems Manager Agent (usually pre-installed)
# sudo yum install -y amazon-ssm-agent
# sudo systemctl enable amazon-ssm-agent
# sudo systemctl start amazon-ssm-agent

# Log completion
echo "EC2 instance setup completed at $(date)" >> /var/log/user-data.log

echo "Setup complete! Web server is running."
