variable "hvprovider" {
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
  type = object({
    name      = string
    processor = number
    memory_gb = number
    notes     = string
  })
  default = {
    name      = "my_awesome_machine"
    processor = 4
    memory_gb = 4
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
    path    = string
    size_gb = number
  })
  default = {
    path    = "C:\\Virtual Machines\\"
    size_gb = 25
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
    switch_name = "VM"
  }
  description = "Network card to be used by the virtual machine"
}
