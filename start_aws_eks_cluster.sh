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
    esac
}
##############
#   Main     #
##############
printf 'Enter Your AWS EKS Cluster Name: '
read -r myEKSCluster

validate $myEKSCluster

asg=$(aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[*].Tags[?Value=='${myEKSCluster}'].{ResourceId:ResourceId}" --output text)
if [ -z "$asg" ]
then
    echo "Please enter a valid EKS cluster name"
else
    echo "Strating your EKS cluster $myEKSCluster"
    for i in $(aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[*].Tags[?Value=='${myEKSCluster}'].{ResourceId:ResourceId}" --output text)
    do
        : 
        maxSize=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name $i --query "AutoScalingGroups[].MaxSize" --output text)
        echo "Setting Auto Scaling Group: $i. Desired capacity to" $maxSize
        aws autoscaling set-desired-capacity \
        --auto-scaling-group-name $i \
        --desired-capacity $maxSize
    done
fi