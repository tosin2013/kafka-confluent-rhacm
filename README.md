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


### Pull podman image
Link: https://catalog.redhat.com/software/containers/rhacm2/subctl-rhel8/
```
$ podman login registry.redhat.io
$ oc image extract registry.redhat.io/rhacm2/subctl-rhel8:v0.14.3-1.1682479377 --path="/dist/subctl-v0.14*-linux-amd64.tar.xz":/tmp/ --confirm --registry-config=/run/user/1001/containers/auth.json
$ tar -C /tmp/ -xf /tmp/subctl-v0.14*-linux-amd64.tar.xz
$ chmod +x /tmp/subctl-v0.14.3/subctl-v0.14.3-linux-amd64
$ sudo mv /tmp/subctl-v0.14.3/subctl-v0.14.3-linux-amd64 /usr/local/bin/subctl
```

**This repository contains the resources to deploy Kafka on OpenShift using ACM.**
Link: https://github.com/confluentinc/confluent-kubernetes-examples
```
git clone https://github.com/confluentinc/confluent-kubernetes-examples.git
cd confluent-kubernetes-examples/hybrid/multi-region-clusters/external-access
```

## Configure OpenShift Clusters with base-configs
```
oc apply -k https://github.com/tosin2013/kafka-confluent-rhacm/base-configs
```

### Hub Cluser 
```
oc apply -k https://github.com/tosin2013/kafka-confluent-rhacm/hubcluster
subctl export service --namespace west zookeeper-hybrid
subctl export service --namespace west zookeeper-hybrid-0-internal
subctl export service --namespace west zookeeper-hybrid-1-internal
subctl export service --namespace west zookeeper-hybrid-2-internal 
```

### Spoke Cluster
```
oc apply -k https://github.com/tosin2013/kafka-confluent-rhacm/spokecluster
subctl export service --namespace west zookeeper-hybrid
subctl export service --namespace west zookeeper-hybrid-0-internal
subctl export service --namespace west zookeeper-hybrid-1-internal
subctl export service --namespace west zookeeper-hybrid-2-internal 
```



## Links: 
* https://www.redhat.com/architect/submariner-acm-add-on
* https://submariner.io/getting-started/quickstart/openshift/aws/