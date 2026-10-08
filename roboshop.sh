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

# echo "Instance Name and ID : "$instance", "$INSTANCE_ID"" 

        if [ "$instance" == "frontend" ]; then
                    IP=$( aws ec2 describe-instances \
                    --instance-ids "$INSTANCE_ID" \
                    --query "Reservations[].Instances[].PublicIpAddress" \
                    --output text          
                    )
                    
            RECORD_NAME="${DOMAIN_NAME}"     #shannu.online    
        else 
                IP=$( aws ec2 describe-instances \
                --instance-ids "$INSTANCE_ID" \
                --query "Reservations[].Instances[].PrivateIpAddress" \
                --output text
                )
             
             RECORD_NAME="$instance.$DOMAIN_NAME"    #mongodb.shannu.online
         
        fi            
        # echo "IP Address :$IP"

          aws route53 change-resource-record-sets \
         --hosted-zone-id "$ZONE_ID" \
         --change-batch '{
          "Comment": "Updating DNS record",
          "Changes": [ {
                        "Action": "UPSERT",
                        "ResourceRecordSet": {
                        "Name":"'$RECORD_NAME'",
                        "Type": "A",
                        "TTL": 60 ,
                        "ResourceRecords": [
                                {
                                 "Value": "'$IP'"
                        }
                     ]
                  }
                }
              ]
            }'
        #  echo "DNS Record Created for $instance : "$RECORD_NAME" -> $IP"
         echo "Instance name and record : "$instance"-> "$RECORD_NAME"  "$IP""
         echo "Everything is done for $instance instance"
done
