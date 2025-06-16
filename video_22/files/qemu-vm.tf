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