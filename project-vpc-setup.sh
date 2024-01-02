#! /bin/bash

# Create VPC
aws ec2 create-vpc --cidr-block 10.0.0.0/16 \
--tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=Project-VPC}]' 


# Create Subnet
aws ec2 create-subnet \
--vpc-id $(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=Project-VPC" --query 'Vpcs[0].VpcId' --output text) \
--cidr-block 10.0.1.0/24 --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Public-Subnet}]'

# Create IGW
aws ec2 create-internet-gateway \
--tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=Project-IGW}]'

# Attach IGN
aws ec2 attach-internet-gateway \
--internet-gateway-id $(aws ec2 describe-internet-gateways --filters "Name=tag:Name,Values=Project-IGW" --query 'InternetGateways[0].InternetGatewayId' --output text) \
--vpc-id $(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=Project-VPC" --query 'Vpcs[].VpcId' --output text)

# Create Route Table
aws ec2 create-route-table \
--vpc-id $(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=Project-VPC" --query 'Vpcs[0].VpcId' --output text) \
--tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=Project-RT-Pub}]'

# Associate RT
aws ec2 associate-route-table \
--route-table-id $(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=Project-RT-Pub" --query 'RouteTables[0].RouteTableId' --output text) \
--subnet-id $(aws ec2 describe-subnets --filters "Name=tag:Name,Values=Public-Subnet" --query 'Subnets[0].SubnetId' --output text)

# Create Route
aws ec2 create-route \
--route-table-id $(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=Project-RT-Pub" --query 'RouteTables[0].RouteTableId' --output text) \
--destination-cidr-block 0.0.0.0/0 \
--gateway-id $(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=Project-VPC" --query 'Vpcs[0].VpcId' --output text)" --query 'InternetGateways[0].InternetGatewayId' --output text)

# Create Security Group
aws ec2 create-security-group \
--group-name project-sg \
--description "Project Security Group" \
--vpc-id $(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=Project-VPC" --query 'Vpcs[0].VpcId' --output text) \
--tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=Project-SG}]'
# SSH, HTTP, HTTPS Ingress Rules
aws ec2 authorize-security-group-ingress \
--group-id $(aws ec2 describe-security-groups --filters Name=tag:Name,Values=Project-SG --query 'SecurityGroups[0].GroupId' --output text) \
--protocol tcp --port 22 --cidr 0.0.0.0/0 
aws ec2 authorize-security-group-ingress \
--group-id $(aws ec2 describe-security-groups --filters Name=tag:Name,Values=Project-SG --query 'SecurityGroups[0].GroupId' --output text) \
--protocol tcp --port 80 --cidr 0.0.0.0/0 
aws ec2 authorize-security-group-ingress \
--group-id $(aws ec2 describe-security-groups --filters Name=tag:Name,Values=Project-SG --query 'SecurityGroups[0].GroupId' --output text) \
--protocol tcp --port 443 --cidr 0.0.0.0/0

# Create Key-Pair
aws ec2 create-key-pair --key-name Project-KP --query 'KeyMaterial' --output text > Project-KP.pem

# Create EC2 Instances
aws ec2 run-instances --image-id ami-0c7217cdde317cfec --count 1 --instance-type t2.micro --key-name Project-KP \
--security-group-ids $(aws ec2 describe-security-groups --filters Name=tag:Name,Values=Project-SG --query 'SecurityGroups[0].GroupId' --output text) \
--subnet-id $(aws ec2 describe-subnets --filters "Name=tag:Name,Values=Public-Subnet" --query 'Subnets[0].SubnetId' --output text) \
--associate-public-ip-address \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=master-node-01}]' \
--user-data file://user-data.txt

aws ec2 run-instances --image-id ami-0c7217cdde317cfec --count 1 --instance-type t2.micro --key-name Project-KP \
--security-group-ids $(aws ec2 describe-security-groups --filters Name=tag:Name,Values=Project-SG --query 'SecurityGroups[0].GroupId' --output text) \
--subnet-id $(aws ec2 describe-subnets --filters "Name=tag:Name,Values=Public-Subnet" --query 'Subnets[0].SubnetId' --output text) \
--associate-public-ip-address \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=worker-node-01}]' \
--user-data file://user-data.txt

aws ec2 run-instances --image-id ami-0c7217cdde317cfec --count 1 --instance-type t2.micro --key-name Project-KP \
--security-group-ids $(aws ec2 describe-security-groups --filters Name=tag:Name,Values=Project-SG --query 'SecurityGroups[0].GroupId' --output text) \
--subnet-id $(aws ec2 describe-subnets --filters "Name=tag:Name,Values=Public-Subnet" --query 'Subnets[0].SubnetId' --output text) \
--associate-public-ip-address \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=worker-node-02}]' \
--user-data file://user-data.txt
