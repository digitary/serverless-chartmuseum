# serverless-chartmuseum
Run serverless Helm repositories using the opensource chart museum project.

### AWS Implementation
The AWS serverless implementation runs chartmuseum in a lambda function. Using API Gateway proxy, the lambda captures the raw https request
and forwards it to the chartmuseum webserver running inside the lambda.

The webserver is initialised on cold start of the lambda. All subsequent requests do not initialise the webserver unless the lambda
environment is destroyed by AWS.

### Deployment
Terraform is used to deploy the solution. The module can be found in **deploy/aws**.

Steps to deploy chartmuseum:

1. Create or select an S3 bucket
2. Clone this repository: 
``git clone https://github.com/RhynoVDS/serverless-chartmuseum``
3. Within the cloned directory, build the solution using the makefile command: 
``make build-lambda``
4. Use terraform to call the module in deploy/aws with the S3 bucket provided. See the file in this repo deploy_example/deploy.tf for an example terraform file.

### Terraform AWS Deployment Module Parameters
When deploying AWS serverless chartmuseum, the following parameters are supported:
 - s3_bucket - A pre-existing bucket to store the helm charts.
 - s3_bucket_region - The region the bucket is in.
 - basic_auth_user - (Optional) When set, chartmuseum will require basic authentication with the given username
 - basic_auth_password - (Optional) The password for the basic authentication user if provided

