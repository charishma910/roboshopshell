#!/bin/bash

AMI=ami-0b4f379183e5706b9
SG_ID=sg-06386db686aed9498    #replace with my security group ID
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
ZONE_ID=Z1018280I2IQGUYPUVNP # need to copy from route53
DOMAIN_NAME=daws76s.shop
for i in "${INSTANCES[@]}"
do
    echo "instance is: $i"
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi

    IP_ADDRESS=$(aws ec2 run-instances \
        --image-id ami-0b4f379183e5706b9 \
        --instance-type $INSTANCE_TYPE \
        --security-group-ids sg-06386db686aed9498 
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" \
        --query 'Instances[0].PrivateIpAddress' --output text)
    echo "$i: $IP_ADDRESS"

    # creating route53 record make sure deleting exisisting record
    aws route53 change-resource-record-sets \
    --hosted-zone-id "$ZONE_ID" \
    --change-batch '


    {
        "Comment": "Create a record set",
        "Changes": [{
        "Action": "CREATE",
        "ResourceRecordSet":{
            "Name": "'$i'.'$DOMAIN_NAME'",
            "Type": "A",
            "TTL": 1,
            "ResourceRecords": [{
                "Value": "'$IP_ADDRESS'"
            }]
        }
        }]
    }'
done