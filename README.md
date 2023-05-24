#  Kafka Deployments using ACM

## Requirements 
*This is an example*
* OpenShift 4.11
* ACM hub Cluster Networks
  * Cluster Network: 10.128.0.0/14
  * Service Network: 172.30.0.0/16
* ACM Managed Cluster Networks
  * Cluster Network: 10.132.0.0/14
  * Service Network: 172.31.0.0/16
* Configure Submariner

## Configure OpenShift Clusters with base-configs
```
oc apply -k https://github.com/tosin2013/kafka-confluent-rhacm/base-configs
```

### Hub Cluser 

### Spoke Cluster

This repository contains the resources to deploy Kafka on OpenShift using ACM.
Link: https://github.com/confluentinc/confluent-kubernetes-examples
```
git clone https://github.com/confluentinc/confluent-kubernetes-examples.git
cd confluent-kubernetes-examples/hybrid/multi-region-clusters/external-access
```



## Links: 
* https://www.redhat.com/architect/submariner-acm-add-on
* https://submariner.io/getting-started/quickstart/openshift/aws/