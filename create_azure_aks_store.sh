#!/bin/bash
set -e
#############
# CONSTS #
#############
AKSAADADMINGROUP="816a876a-6198-4979-ad6e-831706ef895d"
MYSUBSCRIPTION="d1b95759-af4d-4cca-aba1-1dc596810977"
RESOURCEGROUPLOCATION="westeurope"
VMSIZE="Standard_B4ms"

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

function add_nodepool()
{
    nodepool_name=$1
    node_count=$2
    disk_size=$3

    az aks nodepool add \
    --resource-group $MyResourceGroup \
    --cluster-name $MyAksClusterName \
    --name $nodepool_name \
    --node-count $node_count \
    --node-vm-size $VMSIZE \
    --tags "role=${nodepool_name}" \
    --node-osdisk-size $disk_size \
    --labels role=${nodepool_name}

}
function create_cluster()
{
    nodepool_name=$1
    node_count=$2
    disk_size=$3
    
    az aks create \
    --resource-group $MyResourceGroup \
    --name $MyAksClusterName \
    --nodepool-name $nodepool_name \
    --node-count $node_count \
    --aad-admin-group-object-ids $AKSAADADMINGROUP \
    --enable-aad \
    --enable-azure-rbac \
    --nodepool-labels role=${nodepool_name} \
    --node-vm-size $VMSIZE \
    --node-osdisk-size $disk_size
}
##############
#   Main     #
##############
printf 'Enter Your Cluster Name (dash `-` or space ` ` are not allowed, use underline only `_` ): '
read -r MyAksClusterName

validate $MyAksClusterName

# Assign values to variables Workload pool
MyResourceGroup=$MyAksClusterName"_rg"

# Main - login to azure with the @senser.tech user:
az login

# Change to dev subscription
az account set --subscription $MYSUBSCRIPTION

# Create the resource group
az group create --name $MyResourceGroup --location $RESOURCEGROUPLOCATION

# Create the cluster
create_cluster "database" 1 120
# Add the nodepools
add_nodepool "backend" 2 32
add_nodepool "workload" 4 32

# Add the cluster context to ./kube/config
az aks get-credentials --resource-group $MyResourceGroup --name $MyAksClusterName