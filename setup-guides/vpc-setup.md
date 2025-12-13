# VPC Setup Guide

## Prerequisites
- AWS Account with appropriate permissions
- AWS Management Console access
- Understanding of CIDR notation

## Step 1: Create VPC

1. **Navigate to VPC Dashboard**
   - Go to Services → VPC
   - Click "Create VPC"

2. **Configure VPC**
   - Name: `prod-vpc` (or your preferred name)
   - IPv4 CIDR block: `10.0.0.0/16` (adjustable based on requirements)
   - IPv6 CIDR block: No IPv6 (or select if needed)
   - Tenancy: Default
   - Click "Create VPC"

3. **Enable DNS Resolution**
   - Select the created VPC
   - Actions → Edit VPC settings
   - Enable "DNS hostnames"
   - Enable "DNS resolution"
   - Click "Save"

## Step 2: Create Subnets

### Public Subnet - AZ-1
1. VPC Dashboard → Subnets → Create subnet
2. Configuration:
   - VPC ID: Select your VPC
   - Subnet name: `public-subnet-az1`
   - Availability Zone: Select first AZ (e.g., us-east-1a)
   - IPv4 CIDR block: `10.0.1.0/24`
   - Click "Create"

3. Enable auto-assign public IP:
   - Select subnet → Actions → Edit subnet settings
   - Check "Enable auto-assign public IPv4 address"
   - Save

### Public Subnet - AZ-2
1. Repeat the above steps with:
   - Subnet name: `public-subnet-az2`
   - Availability Zone: Select second AZ (e.g., us-east-1b)
   - IPv4 CIDR block: `10.0.2.0/24`

### Private Subnet - AZ-1
1. VPC Dashboard → Subnets → Create subnet
2. Configuration:
   - VPC ID: Select your VPC
   - Subnet name: `private-subnet-az1`
   - Availability Zone: Select first AZ
   - IPv4 CIDR block: `10.0.10.0/24`
   - Click "Create"

### Private Subnet - AZ-2
1. Repeat the above steps with:
   - Subnet name: `private-subnet-az2`
   - Availability Zone: Select second AZ
   - IPv4 CIDR block: `10.0.11.0/24`

## Step 3: Create Internet Gateway

1. VPC Dashboard → Internet Gateways → Create internet gateway
2. Configuration:
   - Name: `prod-igw`
   - Click "Create"

3. **Attach to VPC**
   - Select the created IGW
   - Actions → Attach to VPC
   - Select your VPC
   - Click "Attach"

## Step 4: Create NAT Gateway

1. **Allocate Elastic IP**
   - EC2 Dashboard → Elastic IPs → Allocate new address
   - Click "Allocate"
   - Note the Allocation ID

2. **Create NAT Gateway**
   - VPC Dashboard → NAT Gateways → Create NAT gateway
   - Configuration:
     - Name: `prod-nat-gw-az1`
     - Subnet: Select `public-subnet-az1`
     - Allocation ID: Select the Elastic IP created above
     - Click "Create"

3. **Repeat for AZ-2** (optional for high availability):
   - Allocate another Elastic IP
   - Create NAT gateway in `public-subnet-az2`

## Step 5: Configure Route Tables

### Public Route Table
1. VPC Dashboard → Route Tables → Create route table
2. Configuration:
   - Name: `public-rt`
   - VPC: Select your VPC
   - Click "Create"

3. **Add Internet Gateway Route**
   - Select the route table
   - Routes → Edit routes
   - Add route:
     - Destination: `0.0.0.0/0`
     - Target: Internet Gateway (select your IGW)
     - Click "Save"

4. **Associate Public Subnets**
   - Select route table
   - Subnet Associations → Edit subnet associations
   - Select `public-subnet-az1` and `public-subnet-az2`
   - Click "Save"

### Private Route Table
1. VPC Dashboard → Route Tables → Create route table
2. Configuration:
   - Name: `private-rt`
   - VPC: Select your VPC
   - Click "Create"

3. **Add NAT Gateway Route**
   - Select the route table
   - Routes → Edit routes
   - Add route:
     - Destination: `0.0.0.0/0`
     - Target: NAT Gateway (select your NAT GW)
     - Click "Save"

4. **Associate Private Subnets**
   - Select route table
   - Subnet Associations → Edit subnet associations
   - Select `private-subnet-az1` and `private-subnet-az2`
   - Click "Save"

## Verification Steps

1. **Verify Subnets**
   - All 4 subnets created with correct CIDR blocks
   - Correct AZ assignments

2. **Verify IGW**
   - IGW attached to VPC
   - Status: "Attached"

3. **Verify NAT Gateway**
   - NAT Gateway created and available
   - Elastic IP allocated

4. **Verify Route Tables**
   - Public RT has route to IGW for 0.0.0.0/0
   - Private RT has route to NAT GW for 0.0.0.0/0
   - Correct subnet associations

## Cost Optimization Tips

- NAT Gateway charges apply per hour + data processing
- Consider NAT Instance for non-production or lower traffic
- Single NAT Gateway is cost-effective for non-critical workloads
- Multi-AZ NAT for high availability (increases cost)

## Troubleshooting

- **Cannot access internet from private subnet**: Check NAT Gateway status and route table configuration
- **Public instances can't reach internet**: Verify IGW attachment and route table routes
- **Subnet CIDR conflicts**: Ensure no overlapping CIDR ranges
