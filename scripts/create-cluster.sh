#!/bin/bash

function create_cluster {
  local default_plan="small"
  local network_profile
  local num_nodes
  local wait
  local json_output

   if [ -z "$PKS_CLUSTER_NAME" ]; then
    echo "pks-cluster/create.sh: PKS_CLUSTER_NAME not set"
    return 1
  fi

  if [ -z "$PKS_CLUSTER_HOSTNAME" ]; then
    echo "pks-cluster/create.sh: PKS_CLUSTER_HOSTNAME not set"
    return 1
  fi

  if [ -z "$PKS_CLUSTER_PLAN" ]; then
    echo "pks-cluster/create.sh: PKS_CLUSTER_PLAN not set. Using default: $default_plan"
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

  if [[ $? == 0 ]]; then
      return 0
  fi
  ]/
  return 1
}

function apply_storage_class () {

}

function apply_wavefront_connetor () {

}

function apply_RBAC () {
  
}
