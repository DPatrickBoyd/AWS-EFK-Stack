#! /bin/bash

AZList = $(kubectl get nodes --output="jsonpath={range .items[*]}{.metadata.labels}{'\n'}{end}" | jq '.["topology.kubernetes.io/zone"]')

for i in $AZList
do 
curl -X PUT "localhost:9200/_cluster/settings?flat_settings=true&pretty" -H 'Content-Type: application/json' -d'
{
  "transient" : {
    "indices.recovery.max_bytes_per_sec" : "20mb"
  }
}
'
