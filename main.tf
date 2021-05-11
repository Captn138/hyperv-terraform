terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = "1.0.3"
    }
  }
}

provider "hyperv" {
  user     = var.provider.user
  password = var.provider.password
  host     = var.provider.ip
  port     = var.provider.port
}

resource "hyperv_machine_instance" "my_machine" {
  name                 = var.machine.name
  processor_count      = var.machine.processor
  memory_startup_bytes = var.machine.memory
  notes                = var.machine.notes
  dvd_drives {
    controller_number   = 0
    controller_location = 1
    path                = var.iso_path
  }
  network_adaptors {
    name        = var.network.name
    switch_name = data.hyperv_network_switch.default_switch.name
  }
  hard_disk_drives {
    controller_type     = "Scsi"
    controller_number   = 0
    controller_location = 0
    path                = hyperv_vhd.my_machine_vhd.path
  }
}

resource "hyperv_vhd" "my_machine_vhd" {
  path     = "$(var.vhdx.path)${local.machine_name}.vhdx"
  vhd_type = "Dynamic"
  size     = var.vhdx.size
}

data "hyperv_network_switch" "default_switch" {
  name = var.network.switch_name
}
