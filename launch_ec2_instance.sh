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

# Generate AWS Keys and store in this local box
#echo -e "\e[32m Generating key Pairs\033[0m"
#aws ec2 create-key-pair --key-name devenv-key --query 'KeyMaterial' --output text 2>&1 | tee $ssh_key

#Set read only access for key
#echo "Setting permissions"
#chmod 400 $ssh_key

echo "Creating EC2 instance in AWS"

ec2_id=$(aws ec2 run-instances --image-id $aws_image_id --count 1 --region us-east-1 --instance-type $i_type --key-name $aws_key_name --security-group-ids $sec_id --subnet-id $sub_id --associate-public-ip-address  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$tag - $uid},{Key=WatchTower,Value=$tag},{Key=AutomatedID,Value=$uid}]" | grep InstanceId | cut -d":" -f2 | cut -d'"' -f2)


# Log date, time, random ID. This may come handy in the future for troubleshooting
date >> logs.txt
#pwd >> logs.txt
echo $ec2_id >> logs.txt
echo ""

echo -e "\t\033[0;31mEC2 Instance ID: $ec2_id\033[0m"
#echo "Unique ID: $uid"
elastic_ip=$(aws ec2 describe-instances --instance-ids $ec2_id --query 'Reservations[0].Instances[0].PublicIpAddress' | cut -d'"' -f2)
echo -e "\t \033[0;31mElastic IP: $elastic_ip\033[0m"
echo $elastic_ip >> logs.txt
echo "=====" >> logs.txt

echo ""
countdown_timer=60
echo -e "\e[32m Please wait while your instance is being powered on..We are trying to ssh into the EC2 instance\033[0m"
echo -e "\e[32m Copy/paste the below command to acess your EC2 instance via SSH from this machine. You may need this later.\033[0m"
echo ""
echo -e "\033[0;31m         ssh -i $ssh_key ubuntu@$elastic_ip\033[0m"


temp_cnt=${countdown_timer}
while [[ ${temp_cnt} -gt 0 ]];
do
    printf "\rYou have %2d second(s) remaining to hit Ctrl+C to cancel that operation!" ${temp_cnt}
    sleep 1
    ((temp_cnt--))
done
echo ""


