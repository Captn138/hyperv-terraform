variable "provider" {
  type = object({
    user     = string
    password = string
    ip       = string
    port     = number
  })
  default = {
    user     = "hvadmin"
    password = "p@ssword1234"
    ip       = "127.0.0.1"
    port     = 5986
  }
}

variable "machine" {
  type = objetc({
    name      = string
    processor = number
    memory    = number
    notes     = string
  })
  default = {
    name      = "my_awesome_machine"
    processor = 4
    memory    = 4294967296
    notes     = "this is a superb test"
  }
  description = "The virtual machine to be created"
}

variable "iso_path" {
  type        = string
  default     = "C:\\ISO\\WindowsServer2019.iso"
  description = "Path of the iso file to be loaded into the virtual machine"
}

variable "vhdx" {
  type = object({
    path = string
    size = number
  })
  default = {
    path = "C:\\Virtual Machines\\"
    size = 25000000000
  }
  description = "Vhdx file to be created for the virtual machine"
}

variable "network" {
  type = object({
    name        = string
    switch_name = string
  })
  default = {
    name        = "wan"
    switch_name = "Default Switch"
  }
  description = "Network card to be used by the virtual machine"
}

// output "instance_name" {
//   value = hyperv_machine_instance.my_machine.name
// }
