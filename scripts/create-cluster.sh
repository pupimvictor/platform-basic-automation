#!/bin/bash

function create_cluster {
  printHeader "Creating Cluster - $PKS_CLUSTER_NAME"

  local default_plan="small"
  local network_profile
  local num_nodes
  local wait
  local json_output

  if [ -z "$PKS_CLUSTER_NAME" ]; then
    printErr "PKS_CLUSTER_NAME not set"
    return 1
  fi

  if [ -z "$PKS_CLUSTER_HOSTNAME" ]; then
    printErr "PKS_CLUSTER_HOSTNAME not set"
    return 1
  fi

  if [ -z "$PKS_CLUSTER_PLAN" ]; then
    printInfo "PKS_CLUSTER_PLAN not set. Using default: $default_plan"
    PKS_CLUSTER_PLAN=$default_plan
  fi

  if [ -n "$PKS_CLUSTER_NETWORK_PROFILE" ]; then
    network_profile="--network-profile $PKS_CLUSTER_NETWORK_PROFILE"
  fi

  if [ -n "$PKS_CLUSTER_NUM_NODES" ]; then
    num_nodes="--num-nodes $PKS_CLUSTER_NUM_NODES"
  fi

  if [ -n "$PKS_CLUSTER_WAIT" ]; then
    wait="--wait"
  fi

  if [ -n "$PKS_CLUSTER_JSON_OUT" ]; then
    json_output="--json"
  fi

  pks create-cluster "$PKS_CLUSTER_NAME" --external-hostname "$PKS_CLUSTER_HOSTNAME" --plan "$PKS_CLUSTER_PLAN" \
    $network_profile \
    $num_nodes \
    $wait \
    $json_output

  if [[ $? == 1 ]]; then
      printErr "Couldn't create PKS cluster $PKS_CLUSTER_NAME"
      return 1
  fi
  printStatusMsg "cluster $PKS_CLUSTER_HOSTNAME created with success"
  return 0
}


function apply_RBAC () {
  printHeader "Applying RCABs"

  if [ -z "$ENV" ]; then
    printErr "need target environment (e.g. prod). export ENV with the name of a subdir in the env folder"
    return 1
  fi
  
  if [ ! -f "$__ENV/rbac.yaml" ]; then
    printErr "no rbac resources in $__ENV/rbac.yaml to apply. skipping"
    return 0
  fi

  kubectl apply -f "$__ENV/rbac.yaml"
  if [[ $? == 0 ]]; then
    printStatusMsg "rbac resources applyed to $PKS_CLUSTER_NAME."
    return 0
  fi

  return 1
}

function deploy_ingress_controller () {
  printHeader "Deploying Ingress Controller"

  if [ ! -f "$__ROOT/config/cluster/ingress-ctrller-values.yaml" ]; then
    printErr "missing ingress controller config"
    return 1
  fi


  # check other input vals

  printInfo "creating contour namespace"
  kubectl create namespace contour
  if [[ $? != 0 ]]; then
    printInfo "couldn't create namespace. already exists?"
  fi
  

  helm install contour bitnami/contour \
    --namespace contour \
    --values "$__ROOT/config/cluster/ingress-ctrller.yaml" 
  
  if [[ $? == 1 ]]; then
    printErr "create-cluster.sh: Helm install DIDN'T complete successulfly"
    return 1  
  fi
  
  printStatusMsg "contour ingress controller successuly deployed"
  return 0
  
}

function apply_ingress_spec () {
  printHeader "creating default ingress routes"

  if [ ! -f "$__ENV/ingress.yaml" ]; then
    printInfo "no ingress resources in $__ENV/ingress.yaml to apply. skipping"
    return 0
  fi
  
  kubectl apply -f "$__ENV/ingress.yaml"
  if [[ $? == 0 ]]; then
    printStatusMsg "ingress routes applyed to $PKS_CLUSTER_NAME."
    return 0
  fi

  return 1
}

function apply_storage_class () {
  printHeader "cerating default storage classes for $ENV"

  if [ ! -f "$__ENV/storageclass.yaml" ]; then
    printInfo "no StorageClass resources in $__ENV/storage-class.yaml to apply. skipping"
    return 0
  fi

  kubectl apply -f "$__ENV/storageclass.yaml"
 
  if [[ $? == 1 ]]; then
    printErr "create-cluster.sh: couldn't create storageclasses"
    echo ""
    return 1
  fi

  printStatusMsg "StorageClass set up in $PKS_CLUSTER_NAME"
  return 0
}

function apply_wavefront_connetor () {
  echo noop
  return 1
}

function deploy_dynatrace_oneagent () {
  echo noop
  return 1
}


__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__ROOT=$(dirname $__DIR)

source $__DIR/helpers.sh

if [ -z "$PKS_ENV" ]; then
  printErr "Needs enviroment to target. set export PKS_ENV with one of you environenmet names in $__ROOT/env"
  exit 1
fi
__ENV="$__ROOT/env/$PKS_ENV"

function main {
  if [ -z "$PKS_CLUSTER_CONFIG_VARS" ]; then
    printErr "need configs for the cluster. export PKS_CLUSTER_CONFIG_VARS with the name of a cluster config file in your env dir."
    return 1
  fi
  
  local cluster_template="${__ENV}/$PKS_CLUSTER_CONFIG_VARS"
  source "$cluster_template"

  PKS_CLUSTER_WAIT=true create_cluster
  if [[ $? != 0 ]]; then
    printErr "failed creating cluster $PKS_CLUSTER_NAME"
    return 1
  fi
  
  if [ -n "$PKS_CLUSTER_INSTALL_INGRESS" ]; then
    
    deploy_ingress_controller
    if [[ $? != 0 ]]; then
      printErr "error deploying ingress controller"
      return 1
    fi
  fi
  

  printStatusMsg "cluster $PKS_CLUSTER_NAME successfuly created"
}
main $@
 






