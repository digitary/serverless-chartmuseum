# serverless-chartmuseum
Run serverless Helm repositories using the opensource chart museum project.

### AWS Implementation
The AWS serverless implementation runs chartmuseum in a lambda function. Using API Gateway proxy, all requests are sent to chartmuseum 
which is initialised inside of a lambda. 

### Deployment
Terraform is used to deploy the solution. The module can be found in **deploy/aws**.

Steps to deploy chartmuseum:
1. Clone this repository: 
``git clone https://github.com/RhynoVDS/serverless-chartmuseum``
2. Within the cloned directory, build the solution using the makefile command: 
``make build-lambda``
3. Use terraform to call the module in deploy/aws. See the file in this repo deploy_example/deploy.tf for an example terraform file.