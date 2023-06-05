#!/bin/bash
#To access an individual pod in a specific cluster, prefix the query with <pod-hostname>.<cluster-id>:
# curl web-0.cluster-a.nginx-ss.default.svc.clusterset.local:8080
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
set -x #e 
if [ "$#" -ne 5 ]; then
    echo "Usage: configure-contexts.sh <cluster1_api_url> <cluster2_api_url>  <cluster1_token> <cluster2_token> create|delete"
    exit 1
fi

delete_matching_pod() {
  local namespace="$1"

  local pod_name=$(kubectl get pods -n "$namespace" --selector="app=submariner-lighthouse-agent" -o jsonpath='{.items[].metadata.name}')

  if [[ -n "$pod_name" ]]; then
    echo "Found pod: $pod_name"
    echo "Deleting pod..."
    oc delete pod -n "$namespace" "$pod_name"
    sleep 15s 
    oc get pods -n "$namespace" --selector="app=submariner-lighthouse-agent"
  else
    echo "Pod not found."
  fi
}

wait_for_condition_message() {
  local desired_message="$1"

  while true; do
    local condition_message=$(oc get serviceexport zookeeper-east-0-internal -o jsonpath='{.status}' -n east | jq -r '.conditions[].message')

    if [[ $condition_message == "$desired_message" ]]; then
      echo "Condition message found: $condition_message"
      break
    else
      echo "Condition message is not yet '$desired_message'. Retrying in 5 seconds..."
      delete_matching_pod "submariner-operator"
      sleep 5
      local desired_message=$(oc get serviceexport zookeeper-east-0-internal -o jsonpath='{.status}' -n east | jq -r '.conditions[].message')
    fi
  done
}



# Get the OpenShift cluster names.
cluster1_api_url=$1
cluster2_api_url=$2

# Get the OpenShift cluster credentials.
cluster1_token=$3
cluster2_token=$4

if [ "$5" == "create" ]; then
    oc login --token=${cluster1_token} --server=${cluster1_api_url}
    oc apply -k https://github.com/tosin2013/kafka-confluent-rhacm/clusters/overlay/hubcluster
    sleep 15s
    subctl export service zookeeper-east --namespace east 
    subctl export service zookeeper-east-0-internal --namespace east 
    subctl export service zookeeper-east-1-internal --namespace east 
    subctl export service zookeeper-east-2-internal  --namespace east 
    subctl export service kafka-east --namespace east 
    subctl export service kafka-east-0-internal --namespace east 
    subctl export service kafka-east-1-internal --namespace east 
    subctl export service kafka-east-2-internal --namespace east 
    sleep 15s
    kubectl get ServiceExport -n east 
    sleep 15s
    wait_for_condition_message "ServiceImport was successfully synced to the broker"
    kubectl get ServiceImport -n submariner-operator

    # Log in to the OpenShift cluster2.
    oc login --token=${cluster2_token} --server=${cluster2_api_url}
    oc apply -k https://github.com/tosin2013/kafka-confluent-rhacm/clusters/overlay/spokecluster
    sleep 15s
    subctl export service --namespace west zookeeper-west
    subctl export service zookeeper-west-0-internal --namespace west 
    subctl export service zookeeper-west-1-internal --namespace west 
    subctl export service kafka-west --namespace west 
    subctl export service kafka-west-0-internal --namespace west 
    subctl export service kafka-west-1-internal --namespace west 
    sleep 15s
    kubectl get ServiceExport -n west
    sleep 15s
    kubectl get ServiceImport -n submariner-operator
else

    oc login --token=${cluster1_token} --server=${cluster1_api_url}
    subctl unexport service zookeeper-east --namespace east 
    subctl unexport service zookeeper-east-0-internal --namespace east 
    subctl unexport service zookeeper-east-1-internal --namespace east 
    subctl unexport service zookeeper-east-2-internal  --namespace east 
    subctl unexport service --namespace east kafka-east
    subctl unexport service --namespace east kafka-east-0-internal
    subctl unexport service --namespace east kafka-east-1-internal
    oc delete -k https://github.com/tosin2013/kafka-confluent-rhacm/clusters/overlay/hubcluster

    # Log in to the OpenShift cluster2.
    oc login --token=${cluster2_token} --server=${cluster2_api_url}
    subctl unexport service --namespace west zookeeper-hybrid
    subctl unexport service --namespace west zookeeper-hybrid-0-internal
    subctl unexport service --namespace west zookeeper-hybrid-1-internal
    subctl unexport service --namespace west kafka-west
    subctl unexport service --namespace west kafka-west-0-internal
    subctl unexport service --namespace west kafka-west-1-internal
    oc delete -k https://github.com/tosin2013/kafka-confluent-rhacm/clusters/overlay/spokecluster

fi

# Log in to the OpenShift cluster1.

