# hyperv-terraform
Deploying a HyperV VM, with a Windows Server 2019, with a custom ISO

## Table of Contents

* [hyperv-terraform](#hyperv-terraform)
   * [Prerequisite](#prerequisite)
      * [Execution policy and Hyper-V](#execution-policy-and-hyper-v)
      * [Windows Server 2019 stock ISO](#windows-server-2019-stock-iso)
      * [Terraform software](#terraform-software)
      * [MSMG Toolkit](#msmg-toolkit)
      * [Windows Assessment and Deployment Kit](#windows-assessment-and-deployment-kit)
   * [Customize](#customize)
      * [Customize ISO](#customize-iso)
         * [Auto Unattended XML file](#auto-unattended-xml-file)
         * [Setup Complete CMD script](#setup-complete-cmd-script)
         * [Building the new ISO](#building-the-new-iso)
      * [Customize Terrfaorm variables](#customize-terrfaorm-variables)
   * [Deploy](#deploy)
   * [Destroy](#destroy)

## Prerequisite

### Execution policy and Hyper-V
This will allow us to run PowerShell scripts.  
Open an Administrator PowerShell, then type in
```ps1
# Allow execution of PowerShell scripts
Set-ExecutionPolicy Unrestricted

# Install all Hyper-V additional features
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All

# Enable remote control for Hyper-V
Enable-PSRemoting -SkipNetworkProfileCheck -Force
Set-WSManInstance WinRM/Config/WinRS -ValueSet @{MaxMemoryPerShellMB = 1024}
Set-WSManInstance WinRM/Config -ValueSet @{MaxTimeoutms=1800000}
Set-WSManInstance WinRM/Config/Client -ValueSet @{TrustedHosts="*"}
Set-WSManInstance WinRM/Config/Service/Auth -ValueSet @{Negotiate = $true}
```
Select All scripts.  
Wait for the installation of the Hyper-V modules. You will probably need to reboot after that.

### Windows Server 2019 stock ISO
You can download it from here : https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2019  
Direct download link (fr-fr) : https://software-download.microsoft.com/download/pr/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_fr-fr_1.iso

### Terraform software
This will install Chocolatey and Terraform.  
Open an Administrator PowerShell, then type in
```ps1
# Install Chocolatey
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Terraform
choco install Terraform -y
```

### MSMG Toolkit
You can download it from here : https://www.majorgeeks.com/files/details/msmg_toolkit.html  
Direct download link : https://files1.majorgeeks.com/4212a627b63c7a752e9d10e32b0abf9c84db8744/allinone/Toolkit_v11.4.7z  
Extract it using 7zip.

### Windows Assessment and Deployment Kit
You can download it from here : https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install  
Direct download link : https://go.microsoft.com/fwlink/?linkid=2120254  
Execute `adksetup.exe` and unselect everything unless `Deployment tools`. Install.

## Customize
### Customize ISO
#### Auto Unattended XML file
An Auto Unattended XML files allows installing Windows with predefined values. In my case, I wanted a fully automated installation of Windows, as well as some custom predefined values.  
1. Place your ISO file in the ISO folder in MSMG Toolkit folder.
2. Launch `Start.cmd` in the MSMGT folder (Administrator privileges required).
3. Accept the EULA by pressing `A`.
4. Extract the ISO file : Go to `Source > Extract source from DVD ISO Image` by typing `1 3` and type in the name of your ISO file.
5. You can close MSMGT by typing `X`. Open your startup menu, scroll to `Windows Kits` and open `Windows System Image Manager` (`Assistant Gestion d'Installation`).
6. Click on `File > Select Windows Image`, navigate to `MSMGT > DVD > sources > install.wim`. Select your version of Windows to install. It will ask to build a catalog. Accept (it is a long process).
7. Click on `File > New response file`.
8. Customize your response file. You can find mine in this git repo or you can check some documentation here : https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/automate-windows-setup or https://www.windowscentral.com/how-create-unattended-media-do-automated-installation-windows-10 .
9. Save your response file as `autounattend.xml` and place it in `MSMGT > DVD`

#### Setup Complete CMD script
1. Navigate to `MSMG > DVD > sources`.
2. Create the `$OEM > $$ > Setup > Files` and `$OEM > $$ > Setup > Scripts` folders.
3. Create a new `SetupComplete.cmd` file in the `Scripts` folder.
4. Fill it using the following template :
```bat
@echo off
<YOUR_COMMANDS_HERE>
rd /q /s "%WINDIR%\Setup\Files"
del /q /f "%0"
```
5. Replace the second line by your custom cmd commands. I suggest creating a PowerShell script file in the `Files` folder and calling it using `powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass "%WINDIR%\Setup\Files\myscript.ps1"`. I have added my `post.ps1` script in this git repo. It automatically creates an AD forest and domain controller, as well as fixing the IP address. I strongly advise you to only use this file as an example, as I use custom values for an IP network and AD forest.

#### Building the new ISO
1. Open MSMGT : `MSMGT > Start.cmd` (Administrator privileges required).
2. Accept the EULA by pressing `A`.
3. Build the new ISO file : Go to `Target > Make a DVD ISO Image` by typing `6 1` and type in the label and name of your ISO file to be created.
4. Your ISO file will be located in `MSMG > ISO`.

### Customize Terrfaorm variables
To modify the default variables values, create a `.tfvars` file and set new varaibles values. See https://www.terraform.io/docs/language/values/variables.html.

## Deploy
To run the script, (no Administrator privilege is required) run
```ps1
.\run.ps1
```

## Destroy
To destroy the VM, run
```ps1
.\destroy.ps1
```
