#!/bin/bash

#AWS variable
vpc_id="vpc-7aa17d00"
sub_id="subnet-56b43b78"
route_table="rtb-8a2b70f5"
internet_gateway="igw-3246454a"
sec_id="sg-0a13bde6a33dbbfa3"
aws_image_id="ami-0a313d6098716f372"
i_type="t2.micro"
tag="devops-demo-instance"
aws_key_name="devops-key"
ssh_key="devops-key.pem"
uid=$RANDOM



echo "Creating EC2 instance in AWS"

ec2_id=$(aws ec2 run-instances --image-id $aws_image_id --count 1 --region us-east-2 --instance-type $i_type --key-name $aws_key_name --security-group-ids $sec_id --subnet-id $sub_id --associate-public-ip-address  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$tag - $uid},{Key=WatchTower,Value=$tag},{Key=AutomatedID,Value=$uid}]" | grep InstanceId | cut -d":" -f2 | cut -d'"' -f2)

echo -e "\t\033[0;31mEC2 Instance ID: $ec2_id\033[0m"
#echo "Unique ID: $uid"
elastic_ip=$(aws ec2 describe-instances --instance-ids $ec2_id --query 'Reservations[0].Instances[0].PublicIpAddress' | cut -d'"' -f2)
echo -e "\t \033[0;31mElastic IP: $elastic_ip\033[0m"


ssh -i $ssh_key ubuntu@$elastic_ip
