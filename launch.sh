#!/bin/bash

cd terraform
terraform init
echo yes | terraform apply

echo "=========================================================="
echo ""
echo "Provisioning is finished! The Hello web service is available at: $(terraform output hello_url)"


