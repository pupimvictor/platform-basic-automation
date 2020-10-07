#!/bin/bash

function setup_required_environment_context {
cat << EOF
----------------------------------------------------------------
The following env vars will be used when running 
your acceptance test. Please be sure to set them properly
----------------------------------------------------------------

  export PKS_ENV=...
            (required) vCenter location. ex TPA. Must be the name of one of your enviroments sub-directories
  export PKS_API_HOSTNAME=...
            (required) PKS API hostname
  export PKS_CLUSTER_NAME=...
            (required) PKS cluster name
  export PKS_CLUSTER_HOSTNAME=...
            (required) PKS cluster name
  export PKS_CLUSTER_NETWORK_PROFILE=...
            (optional) PKS Network Profile if needed.
  export TZ_CA_CERT=...
            (optional) PKS API CA certificate
  export TZ_SKIP_SSL=...
            (optional) PKS API skip TLS validation

  
  >>>>>>> Create a file under a environment directory  <<<<<<<<
  >>>>>>> to export those env varibles and export      <<<<<<<<
  >>>>>>> PKS_CLUSTER_CONFIG_VARS=file-name  to use it <<<<<<<<
  
----------------------------------------------------------------
EOF
}

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

  printInfo "creating contour namespace"
  kubectl create namespace contour
  if [[ $? != 0 ]]; then
    printInfo "couldn't create namespace. already exists?"
  fi
  
  helm install contour bitnami/contour \
    --namespace contour \
    --values "$__ROOT/config/cluster/ingress-ctrller.yaml" 
  
  if [[ $? == 1 ]]; then
    printErr "$__THIS: Helm install DIDN'T complete successulfly"
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

function deploy_cert_manager {
  printHeader "Deploying Cert Manager"

  if [ ! -f "$__ROOT/config/cluster/certmanager-ctrller-values.yaml" ]; then
    printErr "missing Cert Manager config"
    return 1
  fi

  printInfo "creating Cert Manager namespace"
  kubectl create namespace cert-manager 
  if [[ $? != 0 ]]; then
    printInfo "couldn't create namespace. already exists?"
  fi
  
  helm install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --values "$__ROOT/config/cluster/certmanager-ctrller-values.yaml" 
  
  if [[ $? == 1 ]]; then
    printErr "$__THIS: Helm install DIDN'T complete successulfly"
    return 1  
  fi
  
  printStatusMsg "Cert Manager successuly deployed"
  return 0

}

function create_dynatrace_resources {
  printHeader "Deploying Dynatrace..."
  printStatusMsg "for more infor, visit https://www.dynatrace.com/support/help/shortlink/connect-kubernetes-clusters#h5-connect-your-kubernetes-cluster-to-dynatrace"

  sleep 3s

  printInfo "creating Dynatrace namespace"
  kubectl create namespace dynatrace
  if [[ $? != 0 ]]; then
    printErr "$__THIS: couldn't create namespace. already exists?"
    return 1
  fi

  kubectl apply -f https://www.dynatrace.com/support/help/codefiles/kubernetes/kubernetes-monitoring-service-account.yaml
  if [[ $? != 0 ]]; then
    printErr "$__THIS: couldn't create svc acct. already exists?"
    return 1
  fi

  k8s_api=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
  if [[ $? != 0 ]]; then
    printErr "$__THIS: couldn't get api"
    return 1
  fi
  printInfo "Kubernetes API URL for later use $k8s_api"

  dynatrace_token=$(kubectl get secret "$(kubectl get sa dynatrace-monitoring -o jsonpath='{.secrets[0].name}' -n dynatrace)" -o jsonpath='{.data.token}' -n dynatrace | base64 --decode)
  if [[ $? != 0 ]]; then
    printErr "$__THIS: couldn't get dynatrace token"
    return 1
  fi

  printHeader "Bearer token for later use: $dynatrace_token"
}

function deploy_dynatrace_oneagent () {
  printStatusMsg "installing OneAgent Operator"
  echo "for more info, visit https://www.dynatrace.com/support/help/technology-support/cloud-platforms/kubernetes/deploy-oneagent-k8/"

  if [ ! -f "$__ROOT/config/cluster/dynatrace-values.yaml" ]; then
    printErr "$__THIS: missing Dynatrace config at $__ROOT/config/cluster/dynatrace-values.yaml"
    return 1
  fi

  helm repo add dynatrace \
    https://raw.githubusercontent.com/Dynatrace/helm-charts/master/repos/stable

  helm install dynatrace-oneagent-operator \
    dynatrace/dynatrace-oneagent-operator -n\
    dynatrace --values "$__ROOT/config/cluster/dynatrace-values.yaml"

  if [[ $? == 1 ]]; then
    printErr "$__THIS: Helm install DIDN'T complete successulfly"
    return 1
  fi

  printStatusMsg "Dynatrace successuly deployed"
  return 0
}

function main {
  if [ -z "$PKS_CLUSTER_ENV" ]; then
    printErr "$__THIS: need configs for the cluster. export PKS_CLUSTER_ENV with the name of a cluster config file in your env dir."
    return 1
  fi
  
  local cluster_template="${__ENV}/$PKS_CLUSTER_CONFIG_VARS"
  if [ -f "$cluster_template" ]; then
    printInfo "sourcing configs in $cluster_template"
    set -x
    source "$cluster_template"
    set +x
  fi

  # Create Cluster
  PKS_CLUSTER_WAIT=true create_cluster
  if [[ $? != 0 ]]; then
    printErr "$__THIS: failed creating cluster $PKS_CLUSTER_NAME"
    return 1
  fi
  
  # Apply StorageClass
  if [ "true" ==  "$PKS_CLUSTER_APPLY_STORAGECLASS" ]; then

    apply_storage_class
    if [[ $? != 0 ]]; then
      printErr "$__THIS error applying storage class"
      return 1
    fi
  fi

  # Apply RBAC
  if [ "true" == "$PKS_CLUSTER_APPLY_RBAC" ]; then

    apply_RBAC
    if [[ $? != 0 ]]; then
      printErr "$__THIS error applying RBAC"
      return 1
    fi
  fi

  # Deploy Ingress Controller
  if [ "true" ==  "$PKS_CLUSTER_DEPLOY_INGRESS" ]; then
    
    deploy_ingress_controller
    if [[ $? != 0 ]]; then
      printErr "$__THIS error deploying ingress controller"
      return 1
    fi
  fi
  
  # Deploy Cert Manager
  if [ "true" ==  "$PKS_CLUSTER_DEPLOY_CERTMAN" ]; then

    deploy_cert_manager
    if [[ $? != 0 ]]; then
      printErr "$__THIS error applying storage class"
      return 1
    fi
  fi

  # Deploy Dynatrace
  if [ "true" ==  "$PKS_CLUSTER_DEPLOY_DYNATRACE" ]; then

    create_dynatrace_resources
    if [[ $? != 0 ]]; then
      printErr "$__THIS error applying storage class"
      return 1
    fi

    deploy_dynatrace_oneagent
    if [[ $? != 0 ]]; then
      printErr "$__THIS error applying storage class"
      return 1
    fi
  fi

  printStatusMsg "cluster $PKS_CLUSTER_NAME successfuly created and configured"
}

setup_required_environment_context

# __CTX: current file path
__CTX="${BASH_SOURCE[0]}"
#echo "$__CTX"

# __THIS: this file name
__THIS=$(basename $__CTX)
#echo "$__THIS"

# __DIR: current dir path
__DIR="$(cd "$(dirname "$__CTX")" && pwd)"
#echo "$__DIR"

# __ROOT: env root
__ROOT=$(dirname $__DIR)
#echo "$__ROOT"

source $__DIR/helpers.sh

if [ -z "$PKS_ENV" ]; then
  printErr "$__THIS: Needs enviroment to target. set export PKS_ENV with one of you environenmet names in $__ROOT/env"
  exit 1
fi
# __ENV: target enviroment config dir 
__ENV="$__ROOT/env/$PKS_ENV"

main "$@"
 






