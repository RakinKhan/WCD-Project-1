#! /bin/bash




# Delete Security Group
aws ec2 delete-security-group \
--group-id $(aws ec2 describe-security-groups --filters Name=tag:Name,Values=Project-SG --query 'SecurityGroups[0].GroupId' --output text)

# #CLI commands to disassociate route tables
aws ec2 disassociate-route-table --association-id $(aws ec2 describe-route-tables --filters "Name=association.subnet-id,Values=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=Public-Subnet" --query 'RouteTables[?Associations == `[]`].RouteTableId' --output text)" --query 'RouteTables[0].RouteTableId' --output text)

# #CLI commands to detach internet gateway
aws ec2 detach-internet-gateway --internet-gateway-id $(aws ec2 describe-internet-gateways --filters "Name=tag:Name,Values=Project-IGW" --query 'InternetGateways[0].InternetGatewayId' --output text) --vpc-id $(aws ec2 describe-vpcs --filters "Name=tage:Name,Values=Project-VPC" --query 'Vpcs[0].VpcId' --output text)

# #CLI commands to delete route tables
aws ec2 delete-route-table --route-table-id $(aws ec2 describe-route-tables --query 'RouteTables[0].RouteTableId' --output text)

# #CLI commands to delete internet gateway
aws ec2 delete-internet-gateway --internet-gateway-id $(aws ec2 describe-internet-gateways --filters "Name=tag:Name,Values=Project-VPC" --query 'InternetGateways[0].InternetGatewayId' --output text)

# #CLI commands to delete subnet
aws ec2 delete-subnet --subnet-id $(aws ec2 describe-subnets --filters "Name=tag:Name,Values=Public-SUbnet" --query "Subnets[0].SubnetId" --output text)

# Delete VPC
aws ec2 delete-vpc --vpc-id $(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=Project-VPC" --query 'Vpcs[0].VpcId' --output text)