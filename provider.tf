terraform {

    required_version = ">= 0.12"
    
    required_providers {
        proxmox = {
            source = "telmate/proxmox"
            version = "2.9.14"
        }
    }
}



variable "proxmox_api_url" {
    type = string
}
variable "proxmox_api_token_id" {
    type = string
    sensitive = true
}
variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}
variable "ssh_key" {
    type = string
}

provider "proxmox" {

    pm_api_url          = var.proxmox_api_url
    pm_api_token_id     = var.proxmox_api_token_id
    pm_api_token_secret  = var.proxmox_api_token_secret
    
    pm_tls_insecure     = true
#    pm_log_file = "terraform-plugin-proxmox.log" #Logging voor het inzien van eventuele fouten
}


resource "proxmox_lxc" "wordpress" {
    count = 10
    target_node = "ProxVM3"
    hostname = "Wordpress-${count.index + 1}"
    ostemplate = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
    password = "terraform"
    unprivileged = true
    cores = 1
    memory = 1024
    swap = 1024
    start =  true
    nameserver = "8.8.8.8"
    ssh_public_keys = <<-EOT
     ${var.ssh_key}
    EOT 

    rootfs {
        storage = "zwembad"
        size = "30G"
    }

    network {
        firewall = "true"
        name = "eth0"
        bridge = "vmbr0"
        gw = "10.24.5.1"
        ip = "10.24.5.${count.index + 31}/24"
        ip6 = "dhcp"
        rate = "480"    
    }

    

}  
