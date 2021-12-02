#! /usr/bin/env bash

source ./environment.sh

az group create --name $RG --location $LOCATION
az aks create --name $CLUSTER_NAME --resource-group $RG --node-count 1
az aks nodepool add --resource-group $RG --cluster-name $CLUSTER_NAME --name wagipool --node-count 1  --workload-runtime wasmwasi

#az aks get-credentials --name $CLUSTER_NAME --resource-group $RG

# az group delete --name $RG --no-wait -y