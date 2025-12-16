### **Overview of Issues Found and How I Resolved & Validated Them**
Below will explain my approach to each issue encountered and actions I took to fix them.

#### **Approach**

After reviewing the files and instructions I determined that the Terraform code is meant to create a k8s namespace for the helm chart to deploy resources to. The Helm Chart creates an nginx webserver customized as defined in values.yaml.  I started out with installing Docker, Kubectl, Minikube, and Terraform on my local workspace. I also set up Git/GitHub for version control. My initial approach was to start with spinning up a Minikube cluster with default config using the docker driver, then deploy the terraform code, and finally the helm chart. 

#### **List of Issues (and Fixes)**

1. When I first tried to run terraform apply, I got a warning saying "k8s_namespace" is deprecated, so I used the recommended version "k8s_namespace_v1" and that resolved the issue.

2. The initial terraform code now could be applied without issue, however, when installing the Helm Chart I encountered an issue where the namespace couldn't be found.  This was because namespace specified in terraform "rc-homework" was different than the one referenced in the helm chart "homework."  To fix this issue, I renamed the namespace in terraform to match the one in the Helm Chart ("homework").  I destroyed and started Minikube, deployed the updated Terraform code successfully, and then tried to install the Helm Chart again, but ran into the next issue. 

3. During this attempt at installing the Helm Chart I got errors with the service and deployment specs:
    - For the spec.ports[0].port value there was an Invalid value error.  This was due to port variable being called in service.yaml having a different name as defined in values.yaml.  I fixed this by renaming the variable in service.yaml to match. 
    - For the spec.ports[0].protocol value there was an unsupported value error.  This was due to a syntax error - the value chosen was "tcp", however the correct syntax is "TCP", so I changed the value to the latter. 
    - For the deployment values (resources.requests in values.yaml), the chosen values exceeded the limits, so I just made memory and cpu the same as the limit values.

The above changes resolved the previous error, and I was able to deploy the helm chart, however I ran into another issue.

4. After looking at the status of the running pods, I noticed the rc-homework pod ran into an error pulling the nginx image.  This was due to the tag specified in values.yaml "1.21-latest" being invalid.  I changed the tag to "1.21" and upgraded the helm chart, and the app deployed successfully. 

5. In order to validate if the install went correctly I needed to connect to the app.  I noticed that the service is of type Cluster-IP, so I decided to just use port-forwarding. However, when I ran the initial port-forwarding command I ran into an error, and I realized it was because the port the container is listening on was different than the one in service.yaml.Specifically, I got a connection refused error because container was listening on 80, but the service.yaml originally said 8080.  I ended up making the service port and container port the same (80).  I changed the source port to 8080 as well.  I reran the kubectl port-forward command (kubectl port-forward svc/rc-homework -n homework 8080:8080) and was able to access the nginx welcome page through my browser by going to http://localhost:8080

