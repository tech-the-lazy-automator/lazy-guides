## Cloud-Init on Proxmox: The VM Automation You’ve Been Missing - #30

[![Thumbnail](https://img.youtube.com/vi/1Ec0Vg5be4s/maxresdefault.jpg)](https://www.youtube.com/watch?v=1Ec0Vg5be4s)

#### Reference Links
 - [Ubuntu Cloud Images](https://cloud-images.ubuntu.com)

#### Cloud-init VM creation

Create a VM using Proxmox GUI using the below instructions
- Machine type - q35
- BIOS - UEFI
- Storage - local
- Default Disk - Remove

##### Commands
```shell
# Download the Image
wget <IMAGE_LINK>

# Modify the Extension to qcow2
mv <IMAGE>.img <NEW_IMAGE_NAME>.qcow2

# Set disk size
qemu-img resize <NEW_IMAGE_NAME>.qcow2 32G

# Attach the disk
qm importdisk <VM_ID> <NEW_IMAGE_NAME>.qcow2 local

# Set serial port
qm set <VM_ID> --serial0 socket --vga serial0
```

##### Cloud-init Configuration

- set user and password
- set IP Config to DHCP
