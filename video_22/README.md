## How I Automate Multiple VMs in Proxmox with Terraform Loops and Variables #22

[![Thumbnail](https://img.youtube.com/vi/WvzppMkebqk/maxresdefault.jpg)](https://www.youtube.com/watch?v=WvzppMkebqk)

All scripts referenced in the video are listed below. You can also download the related files directly from the [files](./files) directory.


#### File Structure
```bash
terraform/
├── credentials.auto.tfvars
├── docker-compose.yml
├── provider.tf
└── qemu-vm.tf
```

#### credentials.auto.tfvars
```hcl
# Proxmox API endpoint, including port and /api2/json suffix
proxmox_api_url = "https://<PROXMOX-IP>:8006/api2/json"

# API token ID in the format: user@auth!token_name
# Example: root@pam!mytoken
proxmox_api_token_id = "<YOUR-TOKEN-ID>"

# API token secret generated from Proxmox
proxmox_api_token = "<YOUR-TOKEN-SECRET>"
```

#### provider.tf
```hcl
terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.1-rc4"
    }
  }
}

variable proxmox_api_url {
  type = string
}

variable proxmox_api_token_id {
  type = string
}

variable proxmox_api_token {
  type = string
}

provider "proxmox" {
  # Configuration options
  pm_api_url = var.proxmox_api_url
  pm_api_token_id = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token
  pm_tls_insecure = true
}
```


#### qemu-vm.tf
```hcl
variable vm_configs {
    type = map(object({
        vm_id = number
        name = string
        cores = number
        memory = number
        vm_state = string
        bridge = string
        tag = number
    }))
    default = {
        "prod-1" = { vm_id = 301, name = "Prod-1", cores = 1, memory = 2048, vm_state = "stopped", bridge = "vmbr0", tag = -1 }
        "prod-2" = { vm_id = 302, name = "Prod-2", cores = 1, memory = 2048, vm_state = "stopped", bridge = "vmbr1", tag = -1 }
        "dev-1" = { vm_id = 304, name = "Dev-1", cores = 1, memory = 2048, vm_state = "stopped", bridge = "vmbr1", tag = -1 }
        "dev-2" = { vm_id = 305, name = "Dev-2", cores = 1, memory = 2048, vm_state = "stopped", bridge = "vmbr1", tag = 4 }
    }
}

resource "proxmox_vm_qemu" "qemu-vm" {
    for_each = var.vm_configs

    vmid = each.value.vm_id
    name = each.value.name
    target_node = "proxmox"

    clone = "Ubuntu-Server"
    full_clone = false
    bios = "ovmf"
    agent = 1
    scsihw = "virtio-scsi-single"

    os_type = "ubuntu"
    cpu = "x86-64-v2-AES"
    sockets = 1
    cores = each.value.cores
    memory = each.value.memory
    
    vm_state = each.value.vm_state

    network {
        model = "virtio"
        bridge = each.value.bridge
        firewall = true
        tag = each.value.tag
    }

    disks {
        scsi {
            scsi0 {
                disk {
                    size = "100G"
                    storage = "local"
                    format = "qcow2"
                }
            }
        }
    }

}
```

#### docker-compose.yml
```yaml
services:
  terraform:
    image: hashicorp/terraform
    volumes:
      - .:/terraform
    working_dir: /terraform
    network_mode: host
```