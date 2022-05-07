setup:
    * uses existing cluster, but I need to use a cluster to test this out. I will need to provision my own to test this out (possibly use minikube if takes too long to provision)
    * use Helm charts where possible
    * lets set up grafana, and have public ingress to test it out as well with security rules that add users IP as an allowance
    * research roles commonly used for ES
    * 

    helm:

    Default way:
        helm install elastic-operator eck-operator -n elastic-system --create-namespace 
