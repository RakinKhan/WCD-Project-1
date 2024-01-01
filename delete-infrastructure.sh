# Delete Security Group
aws ec2 delete-security-group `
--group-id $(aws ec2 describe-security-groups --filters Name=tag:Name,Values=Project-SG --query 'SecurityGroups[0].GroupId' --output text)