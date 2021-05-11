terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = "1.0.3"
    }
  }
}

provider "hyperv" {
  user     = "hvadmin"
  password = "Linux1s@wesome"
  // host     = "172.22.48.1"
  // port     = 5986
}

resource "hyperv_machine_instance" "my_machine" {
  name                 = local.machine_name
  dynamic_memory       = true
  processor_count      = 4
  memory_minimum_bytes = 4294967296
  memory_startup_bytes = 4294967296
  memory_maximum_bytes = 4294967296
  notes                = "this is a superb test"
  dvd_drives {
    controller_number   = 0
    controller_location = 1
    path                = "C:\\Workspace\\NTLite.iso"
  }
  network_adaptors {
    name        = "wan1"
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
  path     = "C:\\Virtual Machines\\${local.machine_name}.vhdx"
  vhd_type = "Dynamic"
  size     = 25000000000
}

data "hyperv_network_switch" "default_switch" {
  name = "Default Switch"
}

locals {
  machine_name = "my_awesome_machine"
}

output "instance_name" {
  value = hyperv_machine_instance.my_machine.name
}