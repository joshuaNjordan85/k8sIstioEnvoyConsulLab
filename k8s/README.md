# k8s
Here, we will go through the steps of configuring our k8s environment and playing around with the necessary commands and such.

## Steps
- install local dependencies
- cloud setup
- enable k8s engine
- create service account
- setup your personal repo
- configure variables after initialization
- deploy infrastructure
- test cluster connectivity

### install local dependencies
You need [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (cube-control) to manage and operate your k8s cluster from a local machine.
- Mac
```bash
brew install kubernetes-cli
```

You will need [helm](https://github.com/helm/helm) too, although we won't use it until later
- Mac
```bash
brew install kubernetes-helm
```

You should have gcloud on your system as well. This way you can manipulate gcp from the local cli.
- [Mac](https://cloud.google.com/sdk/docs/quickstart-macos)
```bash
brew cask install google-cloud-sdk
```
- [Linux](https://cloud.google.com/sdk/docs/quickstart-linux)/[Ubuntu](https://cloud.google.com/sdk/docs/quickstart-debian-ubuntu)
- [Windows](https://cloud.google.com/sdk/docs/quickstart-windows)

### cloud setup
If you're an SE, then you already have access to GCP. If you are a partner, then you may, but HashiCorp isn't paying for it. If you are a partner without GCP, you should find a HashiCorp SE buddy to work with, then let me know so that I can get you configured correctly.

### enable k8s engine
- Navigate to K8s Engine in GCP Console
- Enable the K8s API

### create service account
- Navigate to the IAM section
- Navigate to [Service Accounts](https://console.cloud.google.com/projectselector/iam-admin/serviceaccounts?supportedpurview=project&project=&folder=&organizationId=)
- Create a new service account
- Give it admin credentials
- Generate a .json key_file
- Store the .json key_file locally somewhere you can access later

### setup your personal repo
Today, you will all be leveraging my TFE organization. This means you will be provisioning all of your labs from your own workspace nested in my org. This isn't complicated because you'll be leveraging modules I've written and passing them values particular to your account so that you can spin up the necessary sandbox environments to actually run the labs.

However, you still have to create the repo, then tag it to a workspace in my terraform account. This is going to require coordination between you and me amidst all of the other people in this class, so let the chaos begin:

- checkout a new branch in the following format yourName_k8s_lab
- add a dir according to the following path format k8s/yourName
- copy/paste the k8s/main.tf file into the newly created k8s/yourName dir
- ```bash git add -A && git commit -m 'added <yourName>' && git push origin -u yourName_k8s_lab```
- navigate to the repo url and submit a pull request
- let me know you've submitted a pull request
- after I give you the ok, checkout master and
```bash 
git fetch origin && git pull origin master
```

### configure your workspace
I've already added everyone to my TFE se-training team, so you should be able to access the TFE organization. Since we've all added our new training directories, it's time for you to add your workspace and tag it to the repo.

- Add New workspace
- Title it as yourName_k8s
- point to my repo joshuaNjordan85/k8sIstioEnvoyConsulLab
- click on more options
- set the branch to k8s/yourName
- save

Now you need to configure variables so that we don't have to expose anything sensitive to the world. After you configure your workspace, click on set variables and perform the following steps:

- add a sensitive variable serviceAccount: set the value to the .json credential file you saved earlier that represents your machine identity.
- add a sensitive variable masterAuthPass: set the value to anything you want, but make sure it's at least 16 characters or you will be in trouble. Don't forget it either.

### deploy infrastructure
Queue up your plan and let's watch the magic or disaster...whichever comes first.

### test cluster connectivity
Assuming all went well and we all have k8s clusters on GCP, we should be able to navigate to our cluster from the k8s engine tab from the GCP console. Click on the connect button and copy/paste the gcloud command into your local terminal. Now run ```bash kubectl get nodes``` ... I bet you see your cluster. If you don't, just let me know.

If all is well then we can move on to the k8sWithIstio directory and dig into the tool.
