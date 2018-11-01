# K8s With Consul
We are leveraging [another repo here](https://github.com/hashicorp/demo-consul-101/tree/master/k8s); I just wanted to centralize it for ease as we've changed the workflow a bit. Feel free to check it out in your spare time to dive a bit deeper into things I do not cover.

## Steps
 - helm...see we are going to use it
 - consul...get it running
 - consul kv
 - consul service discovery
 - consul connect
 - consul envoy  
 - clean up


### helm...see we are going to use it
- **NOTE**: you most definitely care about the security warning that pops up, but not today...so ignore it.
```bash
helm init
```
- we need helm charts, so we have to create the rolebinding
```bash
kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
```
- take a look at the helm-consul-values file
```bash
cat helm-consul-values.yaml
```
- clone the consul-helm repo
```bash
git clone https://github.com/hashicorp/consul-helm.git
```
- install the vaules file with helm
```bash
helm install -f helm-consul-values.yaml ./consul-helm
```
- go to GCP consul, check under services, wait for the load balancer ip to be ready, then click and salivate because consul is the prettiest bell at the ball

### consul...get it running
 - if you [like to read about things](https://www.consul.io/docs/platform/k8s/dns.html)
 - check the services...pssst...the one you are looking for is <something>-consul-dns
 ```bash
 kubectl get svc
 ```
 - take a look at the bin script for dns...it's related to the reading I'm sure you skipped over
 ```bash
 cat bin/enable-consul-stub-dns.sh
 ```
 **NOTE**: if you're on windows, please be able to convert this or have cygwin...
 - run dns script
 ```bash
 bin/enable-consul-stub-dns.sh <something>-consul-dns
 ```

### consul k/v
- we are going to need a victim...any client pod will do **NOTE**: you are looking for <some-name>-consul-<someVal>
```bash
kubectl get pods
```
- connect to the chosen one
```bash
kubectl exec -it <some-name>-consul-<someVal> /bin/sh
```
- add some k/v values
```bash
consul kv put redis/config/connections 5
```
- navigate back to the load balancer from GCP consul and see your values alive and well. While you are in the UI, change it to something else.
- check it from the pod
```bash
consul kv get redis/config/connections
```

### consul service discovery
 - inspect the yaml configs for the discovery app
 ```bash
 cat yaml-discovery/*.yaml
 ```
 - create the discovery app
 ```bash
 kubectl create -f yaml-discovery
 ```
 - navigate to GCP K8s cluster/services and wait for load balancer to go look
 - kill this
 ```bash
 kubectl delete -f yaml-discovery
 ```

### consul connect
 - look at the yaml configs for the connect app
 ```bash
 cat yaml-discovery-connect/*.yaml
 ```
 - create discovery with connect
 ```bash
 kubectl create -f yaml-discovery-connect
 ```
 - navigate to GCP k8s cluster/services and wait for load balancer to go look
 - kill
 ```bash
 kubectl delete -f yaml-discovery-connect
 ```
### consul envoy
 - investigate the configs for the envoy app
```bash
cat yaml-discovery-envoy/*.yaml
```
 - create discovery with envoy
 ```bash
 kubectl create -f yaml-discovery-envoy
 ```
 - navigate to GCP k8s cluster/services and wait for laod balancer to go look
 - kill
 ```bash
 kubectl delete -f yaml-discovery-envoy
 ```

### clean up
- get the name of the helm release
```bash
helm list
```
- kill it
```bash
helm delete <release-name>
```
- navigate back to the k8s dir and destroy
```bash
cd ../k8s && terraform destroy
```
