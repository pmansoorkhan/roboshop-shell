#!/bin/bash

SG_ID="sg-0d30c826371107d41"
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z01032422UQPZQPC0HZ2Q"
DOMAIN_NAME="shannu.online"

for instance in "$@"
do 

INSTANCE_ID=$( aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type t3.micro \
    --security-group-ids "$SG_ID" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text
)

echo "Instance Name and ID : " ā$instance" "$INSTANCE_ID"" 

        if [ "$instance" == "frontend" ]; then
                    IP=$( aws ec2 describe-instances \
                    --instance-ids "$INSTANCE_ID" \
                    --query "Reservations[].Instances[].PublicIpAddress" \
                    --output text          
                    )
        else 
                IP=$( aws ec2 describe-instances \
                --instance-ids "$INSTANCE_ID" \
                --query "Reservations[].Instances[].PrivateIpAddress" \
                --output text
        ) 
        fi            
        echo "IP Address :$IP"

done
