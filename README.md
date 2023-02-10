Prisma Cloud Azure CIEM benchmarking Terraform

Update the domain name in the UserCreateTemplate.csv file to the active AD domain you want to create the users in.
bulk import users in Azure AD bulk operations
Azure AD > Users > Bulk Operations > Bulk Create > Upload CSV

download terraform on a linux vm, download azure cli and connect to the tenant using an account that can create and manage resources (vms, networking, storage, ad)

terraform init

terraform apply --auto-approve

#terraform output -raw tls_private_key > id_rsa

#terraform output public_ip_address

#ssh -i id_rsa azureuser@<public_ip_address>
ssh key to login to the VMs created using the template aren't published as an output as you don't need to access the VMs for this test.
Incase you need to login to the VM, run terraform destroy (do not answer yes) and find the key from the terraform prompt.

![image](https://user-images.githubusercontent.com/114196641/203187526-7a99a9b9-b704-4a58-8e4a-15360a80b609.png)


change nsg inbound security rule for ssh to only allow your IP to increase security (optional)

An Azure VM named 'CIEMVM' will be created with a system assigned identity and an Owner+Contributor role.
Another VM named 'CIEM-VM-UserAssigned-Identity' will be created with a user assigned managed identity and a custom key vault access role, you may assign any other custom role or a built in privileged role like Owner, Contributor, Reader etc.

