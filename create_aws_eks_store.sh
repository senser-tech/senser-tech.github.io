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

#yaml-set  -g /metadata/name -a $myEKSCluster create_aws_eks_store.yaml

docker run --rm -v`pwd`:/senser kompose:1 bash -c 'yaml-set -g /metadata/name -a $myEKSCluster /senser/create_aws_eks_store.yaml'


#eksctl create cluster -f create_aws_eks_store.yaml

