terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = "1.0.3"
    }
  }
}

provider "hyperv" {
  user     = var.hvprovider.user
  password = var.hvprovider.password
  host     = var.hvprovider.ip
  port     = var.hvprovider.port
}

resource "hyperv_machine_instance" "my_machine" {
  name                 = var.machine.name
  processor_count      = var.machine.processor
  static_memory        = true
  memory_startup_bytes = var.machine.memory_gb * 1073741824
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
  path     = "${var.vhdx.path}${var.machine.name}.vhdx"
  vhd_type = "Dynamic"
  size     = var.vhdx.size_gb * 1000000000
}

data "hyperv_network_switch" "default_switch" { //resource
  name = var.network.switch_name
  // switch_type = "External"
  // net_adapter_names = ["Wi-Fi"]
}
