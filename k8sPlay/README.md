# K8s Play

## Steps
  - deploy simple resources
  - leverage k8s system commands to analyze
  - clean up

### deploy simple resources
 - please make sure you are in the right dir
 ```bash
 pwd
 ```
 **NOTE**: the output should be /some/crazy/long/thing/k8sPlay
 - look at counting service
 ```bash
 cat yaml-minimal/counting-service.yaml
 ```
 - apply counting service via kubectl
 ```bash
 kubectl apply -f yaml-minimal/counting-service.yaml
 ```
 - check the log to verify all is well **NOTE**: should see Serving at http://localhost:9001 in the stdout
 ```bash
 kubectl get pods && kubectl logs <name of pod>
 ```
 **NOTE**: spoiler alert; the pod's name is counting-minimal-pod
 - it's local, so we can leverage the power of k8s to forward the port...
 ```bash
 kubectl port-forward pod/counting-minimal-pod 9001:9001
 ```
 - then [look at it](http://localhost:9001)
 - now let's look at the load balancer
 ```bash
 cat yaml-minimal/counting-load-balancer.yaml
 ```
 - apply it with kubectl
 ```bash
 kubectl apply -f yaml-minimal/counting-load-balancer.yaml
 ```
 - navigate to GCP console where your K8s cluster lives
  - click on services
  - gasp...a load balancer is running...click on it's IP address **NOTE**: when available
  - e-gasp...it's the output from the counting service...wha..?

### leverage k8s system commands to analyze
  - get pods
  ```bash
  kubectl get pods
  ```
  - get logs for a pod
  ```bash
  kubectl logs <pod name>
  ```
  - set output
  ```bash
  kubectl get pods --output=json
  ```
  - If you've ever used docker, this is very familiar.
  ```bash
  kubectl exec -it <pod name> /bin/sh
  ```

### clean up
We don't need any of this anymore, it was just for fun...please be responsible and kill it!
```bash
kubectl delete -f yaml-minimal/counting-service.yaml && kubectl delete -f yaml-minimal/counting-load-balancer.yaml
```

It's time to go back to lecture...
