#!/bin/bash
set -e
##############
# FUNCTIONS
##############
function validate()
{
    if [ -z "$1" ];then
        echo "Please enter a valid cluster name"
        exit 1
    fi
}
##############
#   Main     #
##############
printf 'Enter Your AWS EKS Cluster Name: '
read -r myEKSCluster

validate $myEKSCluster

asg=$(aws eks list-nodegroups --cluster-name ${myEKSCluster} --query "nodegroups" --output text)
if [ -z "$asg" ]
then
    echo "Please enter a valid EKS cluster name"
else
    echo "Starting your EKS cluster $myEKSCluster"
    for i in $(aws eks list-nodegroups --cluster-name ${myEKSCluster} --query "nodegroups" --output text)
    do
        : 
        maxSize=$(aws eks describe-nodegroup --cluster-name ${myEKSCluster} --nodegroup-name $i --query "nodegroup.scalingConfig.maxSize" --output text)
        echo "Setting Auto Scaling Group: $i. Desired capacity to" $maxSize

        echo "Setting Node Group: $i. Desired capacity to 0"
        aws eks update-nodegroup-config \
        --cluster-name $myEKSCluster \
        --nodegroup-name $i \
        --scaling-config desiredSize=$maxSize
    done
fi