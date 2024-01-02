#! /bin/bash



# CLI commands to terminate insance
aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --filters "Name=tag:Name,Values=master-node-01" --query Reservations[].Instances[].InstanceId --output text )
aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --filters "Name=tag:Name,Values=worker-node-01" --query Reservations[].Instances[].InstanceId --output text )
aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --filters "Name=tag:Name,Values=worker-node-02" --query Reservations[].Instances[].InstanceId --output text )
# Delete Security Group
aws ec2 delete-security-group --group-id $(aws ec2 describe-security-groups --filters "Name=tag:Name,Values=Project-SG" --query 'SecurityGroups[].GroupId' --output text)

# #CLI commands to disassociate route tables
aws ec2 disassociate-route-table --association-id $(aws ec2 describe-route-tables --filters "Name=association.subnet-id,Values=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=Public-Subnet" --query 'RouteTables[?Associations == `[]`].RouteTableId' --output text)" --query 'RouteTables[].RouteTableId' --output text)

#CLI commands to delete route tables
aws ec2 delete-route-table --route-table-id $(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=Project-RT-Pub" --query 'RouteTables[].RouteTableId' --output text)

# CLI Commmands to delete key-pair
aws ec2 cli delete-key-pair --key-name Project-KP
# CLI Command to delete public key from project directory
rm Project-KP.pem

# #CLI commands to detach internet gateway
aws ec2 detach-internet-gateway --internet-gateway-id $(aws ec2 describe-internet-gateways --filters "Name=tag:Name,Values=Project-IGW" --query 'InternetGateways[].InternetGatewayId' --output text) --vpc-id $(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=Project-VPC" --query 'Vpcs[].VpcId' --output text)

# #CLI commands to delete internet gateway
aws ec2 delete-internet-gateway --internet-gateway-id $(aws ec2 describe-internet-gateways --filters "Name=tag:Name,Values=Project-IGW" --query 'InternetGateways[].InternetGatewayId' --output text) --vpc-id $(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=Project-VPC" --query 'Vpcs[].VpcId' --output text)

# #CLI commands to delete subnet
aws ec2 delete-subnet --subnet-id $(aws ec2 describe-subnets --filters "Name=tag:Name,Values=Public-Subnet" --query "Subnets[].SubnetId" --output text)

# Delete VPC
aws ec2 delete-vpc --vpc-id $(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=Project-VPC" --query 'Vpcs[0].VpcId' --output text)