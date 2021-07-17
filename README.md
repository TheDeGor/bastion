## Bastion server for personal usage
### Prerequsites
1. Google cloud SDK
2. gcloud utility is set to proper account and authorized
3. Terraform 1.0.2

### Configuration
To change config use `terraform.tfvars.json` from root directory of project  
Settings are:
1. `project_id` - name of GCP project 
2. `zone` - GCP zone
3. `region` - GCP region
4. `machine_type` - [GSC image type](https://cloud.google.com/compute/docs/machine-types)
5. `boot_disk_images` - OS type of your VM instance. Now one or several of the following allowed: `"ubuntu-os-cloud/ubuntu-2010", "debian-cloud/debian-10", "centos-cloud/centos-stream-8"`. Number of instances calculates from length of this list. For example if `boot_disk_images = ["ubuntu-os-cloud/ubuntu-2010", "debian-cloud/debian-10", "centos-cloud/centos-stream-8"]` then 3 VMs with specified OS will be created
6. `public_key_path` - path to your public ssh key
7. `private_key_path` - path to your private ssh key (is needed for postprovision VMs)
8. `remote_user` - remote user name you want to use
9. `remote_dir` - directory, where postprovision script will be placed remotely
10. `zsh` - install [ZSH](https://ru.wikipedia.org/wiki/Zsh) and use instead of Bash
11. `terraform` - install [Terraform](https://www.terraform.io/)
12. `terraform_version` - Terraform version to install (for example `"1.0.2"`), use it with `terraform = true` setting
13. `ansible` - install [Ansible](https://www.ansible.com/)
14. `kubectl` - install [Kubectl](https://kubernetes.io/ru/docs/reference/kubectl/overview/)
15. `jq` - install [jq](https://stedolan.github.io/jq/)
16. `helm` - install [Helm](https://helm.sh/)
17. `sops` - install [SOPS](https://github.com/mozilla/sops)
18. `sops_version` SOPS version to install (for example `"3.7.1"`), use it with `sops = true` setting
19. `k9s` - install [K9S](https://github.com/derailed/k9s)

#### Have a pleasant use!)

### Links
I used [quickzsh](https://github.com/jotyGill/quickz-sh) in my scripts