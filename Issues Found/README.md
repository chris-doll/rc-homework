### **Overview of Issues Found and How I Resolved & Validated Them**
This section outlines my approach to resolve and validate each issue encountered.

#### **Approach**

After reviewing the project files and instructions, I determined that the Terraform configuration provisions a Kubernetes namespace used by the Helm chart to deploy resources. The Helm chart deploys an NGINX web server customized through values.yaml.

I began by setting up the local development environment, including Docker, kubectl, Minikube, and Terraform, along with Git/GitHub for version control. My workflow consisted of provisioning a Minikube cluster using the Docker driver, applying the Terraform configuration, and then deploying the Helm chart.

#### **List of Issues (and Fixes)**

1. When I first tried to run terraform apply, I got a warning saying "k8s_namespace" is deprecated, so I used the recommended version "k8s_namespace_v1" and that resolved the issue.

2. After successfully applying the Terraform configuration, the Helm chart installation failed due to a missing namespace. This occurred because the namespace defined in Terraform (rc-homework) did not match the namespace referenced in the Helm chart (homework). To resolve this, I updated the Terraform configuration to use the homework namespace. I then recreated the Minikube cluster, reapplied the Terraform configuration, and retried the Helm chart installation, which worked but also surfaced the next issue.

3. During this attempt at installing the Helm Chart I got errors with the Service and Deployment specs:
    - An invalid value error for spec.ports[0].port was caused by a mismatch between the variable name referenced in service.yaml and the variable defined in values.yaml. This was resolved by updating service.yaml to use the correct variable name.
    - An unsupported value error for spec.ports[0].protocol was due to incorrect casing. The value was defined as tcp instead of the required TCP, and was updated accordingly.
    - Deployment resource requests in values.yaml exceeded the defined limits. The CPU and memory request values were adjusted to match the specified limits, resolving the issue.

    The above changes resolved the current errors, however I ran into another issue.

4. After reviewing the status of the running pods, I identified an image pull failure for the rc-homework pod. The issue was caused by an invalid NGINX image tag (1.21-latest) specified in values.yaml. I corrected the tag to 1.21 and upgraded the Helm release, resulting in a successful application deployment.

5. To validate the deployment, I needed to connect to the application. Since the Service was of type ClusterIP, I used port forwarding. However, when I ran it initially I encountered an error, and I found out it was because the port the container was listening on was different than the one in service.yaml.Specifically, I got a connection refused error because container was listening on 80, but the service.yaml originally said 8080.  


To resolve this, I aligned the container port and Service port to 80 and exposed the Service on port 8080 locally. After rerunning the port-forward command (kubectl port-forward svc/rc-homework -n homework 8080:8080), I was able to access and view the NGINX welcome page at http://localhost:8080.


Validation Summary

The deployment was validated by successfully provisioning the Kubernetes namespace with Terraform, deploying the Helm chart without errors, and confirming that all pods and services were in a healthy running state. Application accessibility was verified using kubectl port-forward, and the NGINX welcome page was successfully reached via a local browser, confirming the service was functioning as expected.