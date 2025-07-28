// Description : Creating a virtual machine template under Ubuntu Server 24.04 LTS from ISO file with Packer using VMware Workstation
// Author : Yoann LAMY <https://github.com/ynlamy/packer-ubuntuserver24_04>
// Licence : GPLv3

// Packer : https://www.packer.io/

packer {
  required_version = ">= 1.7.0"
  required_plugins {
    vmware = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

variable "iso" {
  type        = string
  description = "A URL to the ISO file"
  default     = "https://releases.ubuntu.com/noble/ubuntu-24.04.2-live-server-amd64.iso"
}

variable "checksum" {
  type        = string
  description = "The checksum for the ISO file"
  default     = "sha256:d6dab0c3a657988501b4bd76f1297c053df710e06e0c3aece60dead24f270b4d"
}

variable "headless" {
  type        = bool
  description = "When this value is set to true, the machine will start without a console"
  default     = true
}

variable "name" {
  type        = string
  description = "This is the name of the new virtual machine"
  default     = "vm-ubuntuserver24_04"
}

variable "username" {
  type        = string
  description = "The username to connect to SSH"
  default     = "ubuntu"
}

variable "password" {
  type        = string
  description = "A plaintext password to authenticate with SSH"
  default     = "MotDePasse"
}

source "vmware-iso" "ubuntuserver24_04" {
  // Documentation : https://developer.hashicorp.com/packer/integrations/hashicorp/vmware/latest/components/builder/iso

  // ISO configuration
  iso_url      = var.iso
  iso_checksum = var.checksum

  // Driver configuration
  cleanup_remote_cache = false

  // Hardware configuration
  vm_name           = var.name
  vmdk_name         = var.name
  version           = "21"
  guest_os_type     = "ubuntu-64"
  cpus              = 1
  vmx_data = {
    "numvcpus" = "2"
  }
  memory            = 2048
  disk_size         = 30720
  disk_adapter_type = "scsi"
  disk_type_id      = "1"
  network           = "nat"
  sound             = false
  usb               = false

  // Run configuration
  headless = var.headless

  // Shutdown configuration
  shutdown_command = "echo '${var.password}' | sudo -S systemctl poweroff"

  // Http directory configuration
  http_directory = "http"

  // Boot configuration
  boot_command = ["e<wait><down><down><down><end> autoinstall 'ds=nocloud;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'<F10>"]
  boot_wait    = "10s"

  // Communicator configuration
  communicator = "ssh"
  ssh_username = var.username
  ssh_password = var.password
  ssh_timeout  = "30m"

  // Output configuration
  output_directory = "template"

  // Export configuration
  format          = "vmx"
  skip_compaction = false
}

build {
  sources = ["source.vmware-iso.ubuntuserver24_04"]

  provisioner "shell" {
    execute_command="echo '${var.password}' | sudo -S env {{ .Vars }} {{ .Path }}"
    scripts = [
      "scripts/provisioning.sh"
    ]
  }

}
