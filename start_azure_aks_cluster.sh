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
    *"-"*)
    echo "Error, dashes are not allowed"
    exit 1
    ;;
    esac
}
##############
#   Main     #
##############
printf 'Enter Your AKS Cluster Name: '
read -r myAKSCluster
validate $myAKSCluster

myResourceGroup=$(az aks list  --query "[?contains(name,'$myAKSCluster')].resourceGroup" --output tsv)
if [ -z "$myResourceGroup" ]
then
    echo "Please enter a valid AKS cluster name"
else
    echo "Starting your AKS cluster $myAKSCluster, in Resource Group, $myResourceGroup"
    az aks start --name $myAKSCluster --resource-group $myResourceGroup
fi
