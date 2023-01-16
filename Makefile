login:
	fly -t black login -c https://concourse.black.unmanaged.io/


deploy: 
	fly -t black set-pipeline -p infrastructure -c pipeline.yml
	fly -t black unpause-pipeline -p infrastructure
	fly -t black trigger-job --job infrastructure/terraform-plan 
	fly -t black trigger-job --job infrastructure/terraform-apply --watch

clean: 
	fly -t black destroy-pipeline -p infrastructure
	

Build:
	terraform init
	terraform validate 
	terraform plan
	terraform apply


