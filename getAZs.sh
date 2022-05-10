#! /bin/bash

AZ_list=($(kubectl get nodes --output="jsonpath={range .items[*]}{.metadata.labels}{end}" | jq -r '.["topology.kubernetes.io/zone"]'))
node_names=$(kubectl get pods -l app=master -o name -n elastic)
num=0
for i in $node_names
do
    echo $i
    echo $num
    kubectl exec -t -n elastic $i -c elasticsearch -- sh -c "curl -X PUT localhost:9200/_cluster/settings?pretty -H 'Content-Type: application/json' -d'{\"persistent\" :{\"cluster.routing.allocation.awareness.attributes\" :\"zone\"}}'; yq e '.node.attr.zone = \"${AZ_list[$num]}\"' -i '/opt/bitnami/elasticsearch/config/elasticsearch.yml'"
    echo ${AZ_list[$num]}
    num=$(($num + 1))
done

