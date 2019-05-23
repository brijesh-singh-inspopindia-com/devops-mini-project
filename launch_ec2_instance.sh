#!/bin/bash

#AWS variable
vpc_id="vpc-09cb716cf84db6c81"
sub_id="subnet-095879cc20ee6471b"
route_table="rtb-093c26836f0a1e06c"
internet_gateway="igw-082caddba2205b5b9"
sec_id="sg-0a0a7ff9c6298d97d"
aws_image_id="ami-0a313d6098716f372"
i_type="t2.micro"
tag="devops-demo-instance"
aws_key_name="devops-key"
ssh_key="devops-key.pem"
uid=$RANDOM
allocationid_ec2="eipalloc-0c65e06315f674baa"

echo "Creating EC2 instance in AWS"

ec2_id=$(aws ec2 run-instances --image-id $aws_image_id --count 1 --region us-east-1 --user-data ec2-user-data.txt  --instance-type $i_type --key-name $aws_key_name --security-group-ids $sec_id --subnet-id $sub_id --associate-public-ip-address  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$tag - $uid},{Key=WatchTower,Value=$tag},{Key=AutomatedID,Value=$uid}]" | grep InstanceId | cut -d":" -f2 | cut -d'"' -f2)

#associationid_ret=$(aws ec2 associate-address --instance-id $ec2_id --allocation-id $allocationid_ec2 | grep AssociationId)

echo -e "\t\033[0;31mEC2 Instance ID: $ec2_id\033[0m"

elastic_ip=$(aws ec2 describe-instances --instance-ids $ec2_id --query 'Reservations[0].Instances[0].PublicIpAddress' | cut -d'"' -f2)
echo -e "\t \033[0;31mElastic IP: $elastic_ip\033[0m"

echo ""
countdown_timer=120
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
echo whoami

elastic_ip=$(aws ec2 describe-instances --instance-ids $ec2_id --query 'Reservations[0].Instances[0].PublicIpAddress' | cut -d'"' -f2)
sudo su jenkins
cd ~/.ssh/
pwd
echo "sudo cat /var/lib/jenkins/.ssh/id_rsa.pub | sudo ssh  -o StrictHostKeyChecking=no -i /var/lib/jenkins/.ssh/devops-key.pem ubuntu@${elastic_ip} 'cat >> ~/.ssh/authorized_keys'"
sudo cat /var/lib/jenkins/.ssh/id_rsa.pub | sudo ssh  -o StrictHostKeyChecking=no -i /var/lib/jenkins/.ssh/devops-key.pem ubuntu@${elastic_ip} 'cat >> ~/.ssh/authorized_keys'

