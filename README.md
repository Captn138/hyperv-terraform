# hyperv-terraform
Trying to deploy a HyperV VM, with a WinServ2019, with a custom ISO

## Installation
This will install chocolatey and terraform.  
Open an Administrator Powershell, then type in
```ps1
Set-ExecutionPolicy Unrestricted
.\install.ps1
```

## Run
To run the script, (no Administrator privilege is required) run
```ps1
.\run.ps1
```

## Modify
To modify the default variables values, create a `.tfvars` file and set new varaibles values. See https://www.terraform.io/docs/language/values/variables.html .