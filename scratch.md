setup:
   * pipeline will include two sections
      1. provision dummy review app, check to see that PV/PVC is created, it not it will do it. This it will check and see that the dummy app is producing data and that it can connect to the PV or db
      2. provision fluentd and ES components 
         a. optional, shard allocation, multi-master ES nodes (min 3 nodes? 2 with master). If possible use a k8s job to get k8s node info and then include that in sharding attributes so each k8s node has a fully shard of data 
         b. something like this https://phoenixnap.com/kb/elasticsearch-kubernetes
    * uses existing cluster, but I need to use a cluster to test this out. I will need to provision my own to test this out (possibly use minikube if takes too long to provision)
    * use Helm charts where possible, but possible will need custom roles for fluentd.
    * set up kibana, and have public ingress to test it out as well with security rules that add users IP as an allowance (if possible)
    * research roles commonly used 
    * use fluentd for aggregator
    * create dummy service and namespace to mimic the review service
      * create PV and PVC in review ns, either as blob data or db (mongodb? cassandra?)
      * fluentd will pass on real-time logs from stdout or java equivalent and grab data from PV
   * fluentd will pass to ES, make note that fluentd was used instead of logstash to avoid queue issues, like installing Redis. will also scale better due to less memory taken up, can ship out stdout without any extra config
   * for HA https://www.elastic.co/guide/en/elasticsearch/reference/current/high-availability-cluster-small-clusters.html and https://www.elastic.co/guide/en/elasticsearch/reference/current/high-availability-cluster-design-large-clusters.html
      * shard allocation awareness might be too much detail? https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-cluster.html#shard-allocation-awareness
   * use binary data as a raw dump for sample unstructured data, first steps of plan will be to create namespace for dummy app, create PV/PVC, and then upload raw data to it
      *  
   * No need to use https/certs, since there will be no ingress. However, we could use a public ingress for kibana. add option for kibana for on/off and mayvbe spot for IP address to add exception for nsg
