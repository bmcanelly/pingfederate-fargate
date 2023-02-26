# pingfederate-fargate
initial Terraform for PingFederate and PingFederate Admin ECS/Fargate containers


### Requirements ###
* [Terraform](http://terraform.io/downloads.html) Version 1 or newer
* Existing domains and domain certificates required from `data.tf` files
* Existing EFS volumes with configurations/files for (in) /opt/in mounts for pingfederate container and /opt/in and /opt/out/instance/service/default/data (data) mounts - import with `terraform import` from `efs.tf` files in [va/tst](va/tst) or [va/prd](va/prd) depending on environment
* Existing Systems Manager parameters/secrets and environment vars updated in va/tst/configs or va/prd/configs ECS container json definitions 


### Optional ###
* S3 Bucket for ALB logging (or comment out)
* S3 Bucket for terraform remote state in s3 (uncomment and configure in `_config.tf` files)


### [VA TST APP](va/tst/) ###
Virginia AWS Test Application resources


### [VA PRD APP](va/prd/) ###
Virginia AWS Production Application resources


### Procedures ###
- get requirements setup
- config applied in [va](va/) to create VPC and all other resources
- apply [test](va/tst/) or [production](va/prd/) as needed 


### Todo ###
* Pull in WAF/GlobalAccelerator configs
* Automate more requirements
* HA to another region
* Cleanup
