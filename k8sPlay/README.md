# K8s Play

## Steps
  - deploy simple resources
  - leverage k8s system commands to analyze
  - clean up

### deploy simple resources
 - please make sure you are in the right dir
 ```
 pwd
 ```
 **NOTE**: the output should be /some/crazy/long/thing/k8sPlay
 - look at counting service
 ```
 cat yaml-minimal/counting-service.yaml
 ```
 - apply counting service via kubectl
 ```
 kubectl apply -f yaml-minimal/counting-service.yaml
 ```
 - check the log to verify all is well **NOTE**: should see Serving at http://localhost:9001 in the stdout
 ```
 kubectl get pods && kubectl logs <name of pod ... spoiler alert; it's counting-minimal-pod>
 ```
 - it's local, so we can leverage the power of k8s to forward the port...
 ```
 kubectl port-forward pod/counting-minimal-pod 9001:9001
 ```
 - then [look at it](http://localhost:9001)
 - now let's look at the load balancer
 ```
 cat yaml-minimal/counting-load-balancer.yaml
 ```
 - apply it with kubectl
 ```
 kubectl apply -f yaml-minimal/counting-load-balancer.yaml
 ```
 - navigate to GCP console where your K8s cluster lives
  - click on services
  - gasp...a load balancer is running...click on it's IP address **NOTE**: when available
  - e-gasp...it's the output from the counting service...wha..?

### leverage k8s system commands to analyze
  - ```kubectl get pods```
  - ```kubectl logs <pod name>```
  - ```kubectl get pods --output=json```
  - If you've ever used docker, this is very familiar:
  ```
  kubectl exec -it <pod name> /bin/sh
  ```

### clean up
We don't need any of this anymore, it was just for fun...please be responsible and kill it!
```
kubectl delete -f yaml-minimal/counting-service.yaml && kubectl delete -f yaml-minimal/counting-load-balancer.yaml
```

It's time to go back to lecture...
