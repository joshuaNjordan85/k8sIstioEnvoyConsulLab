# k8s with istio
You've been instructed to this README because your k8s environment is up and running. This means you are _hopefully_ excited about digging into Istio a bit more. This is going to be very basic as the intention is to get you somewhat familiarized with the concepts we've been discussing thus far.

## Steps
- install dependencies
- install istio in the cloud
- deploy an app
- setup an ingress gateway to see the app
-

### install dependencies
Istio's control plane is installed in its own Kubernetes istio-system namespace, but it can manage microservices from all other namespaces. What we are going to install is the core components, tools, and some samples. As you go through this, keep in the back of your mind that we are using a ton of pre-written configs, and that is really cutting down the work we would have to do if we were starting from scratch.

**NOTE**: We are purposefully using **Istio 1.0.0**, so don't just navigate to the release page and start pulling versions. You can use a package manager if it allows you to specify versions, but you are just as well off leveraging curl to pull the version needed...and that's what the next steps outline.

[Istio Release Page](https://github.com/istio/istio/releases)
 - create a directory for this lab; I don't care where, but here's an example
 ```
 mkdir ~/se-training && mkdir ~/se-training/k8sIstio && cd ~/se-training/k8sIstio
 ```
 - get your Istio version 1.0.0
 ```
 curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.0.0 sh -
 ```
 - you will have instructions post installation for how to add istioctl to your $PATH:
   - you can follow those directions
   - you can do so manually
   ```
   mv istio-1.0.0/bin/istioctl /usr/local/bin || cp istio-1.0.0/bin/istioctl /usr/local/bin
   ```
 - check your installation
 ```
 which istioctl
 ```
 - make sure it works
 ```
 istioctl version
 ```
 - gke rbac config
 ```
 kubectl create clusterrolebinding cluster-admin-binding \
 --clusterrole=cluster-admin \
 --user=$(gcloud config get-value core/account)
 ```
 - pause for collateral damage

### install istio in the cloud
 - make sure you are in the istio-1.0.0 dir that we downloaded in the previous section: ```cwd```
 - if the previous step's output doesn't look like
 ```
 <some>/<path>/<you>/<defined>/istio-1.0.0
 ```
 then
 ```
 cd <some>/<path>/<you>/<defined>/istio-1.0.0
 ```
 - install resource definitions
 ```
 kubectl apply -f install/kubernetes/helm/istio/templates/crds.yaml
 ```
 **NOTE**: _if you remember the k8s resource definition bit from earlier, then you recognize that we just pushed a ton of resources that describe what our pod environment should look like with istio in it and istio knows how/where to get these resources_
 - install istio and associated services into our gke environment
```
kubectl apply -f install/kubernetes/istio-demo-auth.yaml
```
 - review what we installed
 ```
 kubectl get svc -n istio-system
 ```
 - **TAKE NOTE OF THE LoadBalancer IP**
 ```
 export K8S_ISTIO_HOST=<whatever it is>
 ```
 - check the status of everything
 ```
 kubectl get pods -n istio-system || kubectl get pods -n istio-system -w
 ```
 - **YOU CAN'T DO ANYTHING UNLESS EVERYTHING IS RUNNING OR COMPLETED UNLESS YOU PREFER TO CRY**
 - If it's 0/1 Completed, you're ok, if it's 1/2 Running, you're not!
 - pause for collateral damage

### deploy an app
We will be deploying the application the Istio dev peeps use when they want to test new features...what fun. It's a book review application...so if you like to read...you'll love this. All of the source code for the app is in ```istio-1.0.0/samples/bookinfo``` if you are interested in digging into the particulars.
 - check out the yaml for bookinfo
 ```
 cat samples/bookinfo/platform/kube/bookinfo.yaml
 ```
 - reflect, reason, and discuss: **NOTE**: _there's nothing istioish about this config. It's just the k8s way, so, if we want to spice up our k8s tea, we need to inject this config with istioctl (lol...I bet you were wondering when we were going to use it!)_
 - check out the yaml for bookinfo with istioness applied to it
 ```
 istioctl kube-inject -f samples/bookinfo/platform/kube/bookinfo.yaml
 ```
 - set up a namespace for auto-injection
 ```
 kubectl label namespace default istio-injection=enabled
 ```
 - now apply the istio config to the cluster
 ```
 kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
 ```
 - check your pods
 ```kubectl get pods
 ```
 **NOTE**: _there's more than one container; the second one is the istio proxy_
 - check your services
 ```
 kubectl get services
 ```
 - pause for collateral damage

### setup an ingress gateway to see the app
We can't see anything yet, we actually have to setup the istio ingress so it can start routing traffic to the productpage for us. We are also going to make sure we are forwarding between teh right version of the applications we are running, so we will add a set of destination rules between the different services, ensuring that version traffic is forwarded properly. Let's do that now.
 - observe the gateway yaml
 ```
 cat samples/bookinfo/networking/bookinfo-gateway.yaml
 ```
 - apply it
 ```
 kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
 ```
 - observe the destination rules
 ```
 cat samples/bookinfo/networking/destination-rule-all-mtls.yaml
 ```
 - create the destination rules
 ```
 kubectl create -f samples/bookinfo/networking/destination-rule-all-mtls.yaml
 ```
 - store HOST
 ```
 export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}') && echo $INGRESS_HOST
 ```
 - store IP
 ```
 export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}') && echo $INGRESS_PORT
 ```
 - build gateway
 ```
 export GATEWAY_URL=${INGRESS_HOST}:${INGRESS_PORT}
 ```
 - set your firewall rule
 ```
 gcloud compute firewall-rules create allow-book --allow tcp:${INGRESS_PORT},tcp:443
 ```
 **NOTE**: if Failure
 ```
 gcloud compute firewall-rules update allow-book --allow tcp:${INGRESS_PORT},tcp:443
 ```
 - observe the bookinfo-gateway config
 ```
 cat samples/bookinfo/networking/bookinfo-gateway.yaml
 ```
 - connect the istio ingress to the services
 ```
 kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
 ```
 - observe your monster
 ```
 echo http://${GATEWAY_URL}/productpage || echo http://${GATEWAY_URL}/productpage | pbcopy
 ```

### configure routing
Now we are going to transition a bit into istioctl usage. The goal is to play around with our traffic, managing it in various ways.
 - what are our current rules
 ```
 istioctl get destinationrules
 ```
 - look at service rules
 ```
 cat samples/bookinfo/networking/virtual-service-all-v1.yaml
 ```
 - create the rules
 ```
 kubectl create -f samples/bookinfo/networking/virtual-service-all-v1.yaml
 ```
 - did it work?
 ```
 kubectl get virtualservice -o yaml
 ```
 - go back to url and lets talk about it a bit
 - look at a different service route rule
 ```
 cat samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml
 ```
 - apply new service route rule
 ```
 kubectl apply -f samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml
 ```
 - go back to url and lets talk about it a bit
 - look at yet another service route rule
 ```
 cat samples/bookinfo/networking/virtual-service-reviews-50-v3.yaml
 ```
 - apply new service route rule
 ```
 kubectl apply -f samples/bookinfo/networking/virtual-service-reviews-50-v3.yaml
 ```
 - look at final service route rule
 ```
 cat samples/bookinfo/networking/virtual-service-reviews-v3.yaml
 ```
 - apply final service route rule
 ```
 kubectl apply -f samples/bookinfo/networking/virtual-service-reviews-v3.yaml
 ```

### clean up
We're done...clean up after yourself please!
 - uninstall Istio from cloud
 ```
 kubectl delete -f samples/bookinfo/platform/kube/bookinfo.yaml
 ```
 - uninstall the auth too
 ```
 kubectl delete -f install/kubernetes/istio-demo-auth.yaml
 ```
 - use terraform to delete the cloud resources
