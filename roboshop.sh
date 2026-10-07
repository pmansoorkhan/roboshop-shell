#!/bin/bash

SG_ID="sg-0d30c826371107d41"
AMI_ID="ami-0220d79f3f480ecf5"


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

echo "instance id : $INSTANCE_ID" 

        if [ $INSTANCE_ID == "frontend" ]; then
                    IP=$( aws ec2 describe-instances \
                    --instance-ids "$INSTANCE_ID" \
                    --query 'Reservations[0].Instances[0].PublicIpAddress'\
                    --output text          
                    )
        else 
                IP=$( aws ec2 describe-instances \
                --instance-ids "$INSTANCE_ID" \
                --query 'Reservations[0].Instances[0].PrivateIpAddress' \
                --output text
        ) 
        fi            
        echo "IP Address :$IP"

done
