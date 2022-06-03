# Elasticsearch on Kubernetes
[INSTRUCTIONS.md]: ./INSTRUCTIONS.md

## Introduction:

The following is a full EFK setup that includes Elasticsearch (3 nodes, all with every role needed), Kibana, Fluentd, and a dummy logging app that generats random words to verify that the logging is working as intended. It is intended to be ran on AWS with EKS. Ensure that you have 3 node pools, with 3 subnets that are assigned to their own availability zones. Here is more information on this topic: https://aws.amazon.com/blogs/containers/amazon-eks-cluster-multi-zone-auto-scaling-groups/ . The logging app is meant to simulate real-time data that could be coming in from a hypothetical application/microservice. I used vanilla manifests for this to give an clear idea of what is happening.

### Assumptions:
  * The user has a way of directly accessing this cluster, including forwarding ports, etc. If this was not the case, you could create a LoadBalancer IP such as "service.beta.kubernetes.io/aws-load-balancer-type: nlb" type, and terminate TLS on an nginx controller with certs in order to give them access to the Kibana dashboard. This would require potentially white-listing IPs or something similar if need be.
  * The cluster has at *least* 3 separate availability zones (AZ) and kubernetes nodes attached to those AZs. If they do not, it will still work (I used a preferred antiNodeAffinity setting instead of requiring a unique AZ per node) but there will be a possible situation where there is only one master node, which is not advised.
  * There is enough memory/CPU to fit all the resources. If not, specs will need to be adjusted. Elasticsearch especially will likely need to be expanded if you intend to use it for more than anything simple.

### Features of the setup:
  * each ES node is assigned a node attribute called "zone" that is passed to the shard allocation awareness setting within ES config. This value is dynamically assigned to each node. This also means that the shard allocation will be evenly distributed among AZs. This one took me the longest to figure out. I did this with a configMap loaded as a file that exports the dynamic variable which is passed into the config file, which is also mounted as a configMap.
  * a fully functioning Kibana dashboard with the index already set up. If this was going to be publicly exposed it would have more security.
  * uses fluentd to forward/aggregate logs. 
  * has a "logger" app that will spit out lorem ipsum text every five seconds. You can search for this in the Kibana "discovery" webpage using the search 'kubernetes.namespace_name : "logger"'.


## ES Setup:
```
$ cd ./manifests/elastic/templates

# Apply the service, namespace, etc
$ kubectl apply -f service.yaml
$ kubectl apply -f configenv.yaml

# Apply configMap, notice the "ZONE" varible that will get set prior to the Entrypoint
$ kubectl apply -f configmap.yaml
$ kubectl apply -f poddisruptionbudget.yaml

# Apply the stateful set. The pods may take up to 2 minutes before they show healthy. 
# If you want to verify that the clusters are in fact set to different AZs, exec inside of a master pod like this `kubectl exec -i -t -n elastic elasticsearch-master-0 -c elasticsearch -- sh -c "clear; (bash || ash || sh)"` and 
`curl http://localhost:9200/_cluster/state?pretty | more`. 
# You can hit enter to scroll and see the attributes of the different nodes, including something like "zone" : "us-west-2b".

$ kubectl apply -f statefulset.yaml
```

## Fluentd Setup:
```
$ cd ./manifests/fluentd/templates
# Create ServiceAccount, ClusterRole, and ClusterRoleBinding
$ kubectl apply -f service-account.yaml
# Apply daemonset
$ kubectl apply -f daemonset.yaml
# Once again, if this was a public cluster, I would be more careful about the permissions given to the ServiceAccount, possibly limit it from the masters.
```

## Kibana Setup:
```
$ cd ./manifests/kibana/templates

# Deploy service and deployment
$ kubectl apply -f service.yaml
$ kubectl apply -f deployment.yaml

# You can port forward the Kibana UI by running  `kubectl port-forward pods/<name of pod> 5601:5601 -n elastic`. Then head to http://localhost:5601/app/home#/ in your browser. To stop port forwarding, just press Control+C.
```
## Logging App Setup:
```
$ cd ./manifests/logger/templates
$ kubectl apply -f loggerpod.yaml
```

#### Once you have deployed the logger pod, give it a few minutes to hit Kibana, you can see the logs from the app using kubernetes.namespace_name : "logger" search.

---------

This is a fairly simple set up, and your individual set up may require more specifics. Please consult the official helm charts in order to see all options available and for any issues.


 
