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

    case $1 in
    *"demo"*)
    echo "Error, don't touch the demo"
    exit 1
    ;;
    esac
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
    echo "Did not find the cluster:  $myEKSCluster. Please enter a valid EKS cluster name"
else
    echo "Stopping your EKS cluster $myEKSCluster"
    for i in $(aws eks list-nodegroups --cluster-name ${myEKSCluster} --query "nodegroups" --output text)
    do
        : 
        echo "Setting Auto Scaling Group: $i. Desired capacity to 0"
        aws autoscaling set-desired-capacity \
        --auto-scaling-group-name $i \
        --desired-capacity 0
    done
fi