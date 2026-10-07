#!/bin/bash

SG_ID="sg-0d30c826371107d41"
AMI_ID="ami-0220d79f3f480ecf5"


for INSTANCE in $@    # mongodb
do 

INSTANCE_ID=$( aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type t3.micro \
    --security-group-ids "$SG_ID" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE}]" \
    --query 'Instances[0].InstanceId' \
    --output text
)

        if [ "$INSTANCE_ID"=="$INSTANCE" ]; then
                    IP_ADDRESS=$(
                aws ec2 describe-instances \
                    --instance-ids "$INSTANCE_ID" \
                    --query "Reservations[].Instances[].PublicIpAddress" \
                    --output text          
                    )
        else 
                IP_ADDRESS=$(
            aws ec2 describe-instances \
                --instance-ids "$INSTANCE_ID" \
                --query "Reservations[].Instances[].PrivateIpAddress" \
                --output text
        ) 
        fi            
echo "IP Address :$IP_ADDRESS"

done
