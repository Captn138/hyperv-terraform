# hyperv-terraform
Déployer une VM Hyper-V, contenant un Windows Server 2019 avec un ISO personnalisé

## Table des matières

* [Prérequis](#prérequis)
   * [Politique d'exécution et Hyper-V](#politique-dexécution-et-hyper-v)
   * [ISO Windows Server 2019](#iso-windows-server-2019)
   * [Logiciel Terraform](#logiciel-terraform)
   * [MSMG Toolkit](#msmg-toolkit)
   * [Windows Assessment and Deployment Kit](#windows-assessment-and-deployment-kit)
* [Personnalisation](#personnalisation)
   * [Personnaliser l'ISO ISO](#personnaliser-liso-iso)
      * [Fichier XML Auto Unattended](#fichier-xml-auto-unattended)
      * [Script CMD Setup Complete](#script-cmd-setup-complete)
      * [Ignorer l'entrée utilisateur au moment du boot](#ignorer-lentrée-utilisateur-au-moment-du-boot)
      * [Construire le nouvel ISO](#construire-le-nouvel-iso)
   * [Personnaliser les variables Terraform](#personnaliser-les-variables-terraform)
* [Déploiement](#déploiement)
* [Destruction](#destruction)

## Prérequis

### Politique d'exécution et Hyper-V
Cela nous permettra d'exécuter des scripts PowerShell.  
Ouvrez PowerShell en Administrateur, puis tapez
```ps1
# Autoriser l'exécution de scripts PowerShell
Set-ExecutionPolicy Unrestricted

# Installer Hyper-V et ses composants
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All

# Activer le pilotage à distance pour Hyper-V
Enable-PSRemoting -SkipNetworkProfileCheck -Force
Set-WSManInstance WinRM/Config/WinRS -ValueSet @{MaxMemoryPerShellMB = 1024}
Set-WSManInstance WinRM/Config -ValueSet @{MaxTimeoutms=1800000}
Set-WSManInstance WinRM/Config/Client -ValueSet @{TrustedHosts="*"}
Set-WSManInstance WinRM/Config/Service/Auth -ValueSet @{Negotiate = $true}
```
Sélectionnez `Autorisez pour tous`.  
Attendez l'installation des modules Hyper-V. Vous aurez probablement besoin de redémarrer après.

### ISO Windows Server 2019
Vous pouvez le télécharger depuis cette page : https://www.microsoft.com/fr-fr/evalcenter/evaluate-windows-server-2019  
Téléchargement direct (fr-fr) : https://software-download.microsoft.com/download/pr/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_fr-fr_1.iso

### Logiciel Terraform
Cela va installer Chocolatey et Terraform.  
Ouvrez PowerShell en Administrateur, puis tapez
```ps1
# Installer Chocolatey
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Installer Terraform
choco install Terraform -y
```

### MSMG Toolkit
Vous pouvez le télécharger depuis cette page : https://www.majorgeeks.com/files/details/msmg_toolkit.html  
Extrayez-le en utilisant 7-zip.

### Windows Assessment and Deployment Kit
Vous pouvez le télécharger depuis cette page : https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install  
Téléchargement direct : https://go.microsoft.com/fwlink/?linkid=2120254  
Executez `adksetup.exe` et désélectionnez tout sauf `Deployment tools`. Installez.

## Personnalisation
### Personnaliser l'ISO ISO
#### Fichier XML Auto Unattended
Un fichier XML Unattend permet l'installation de Windows avec des valeurs prédéfinies. Dans mon cas, je voulais une installation 100% automatique, ainsi que quelques valeurs prédéfinies.   
1. Placez votre fichier ISO dans le dossier `ISO` du dossier MSMG Toolkit.
2. Exécutez `Start.cmd` dans le dossier MSMGT (privilèges Administrateur requis).
3. Acceptez les conditions d'utilisation en tapant `A`.
4. Extrayez le fichier ISO : Allez à `Source > Extract source from DVD ISO Image` en tapant `1 3` puis tapez le nom de votre fichier ISO.
5. Vous pouvez fermer MSMGT en tapant `X`. Ouvrez le menu démarrer, descendez à `Windows Kits` et ouvrez `Assistant Gestion d'Installation`.
6. Cliquez sur `Fichier > Sélectionner l'image Windows`, naviguez à `MSMGT > DVD > sources > install.wim`. Selectionnez la version de Windows que vous souhaitez personnaliser. Cela vous demandera de construire un catalogue. Acceptez (c'est un processus long, privilèges Administrateur requis).
7. Cliquez sur `Fichier > Nouveau fichier de réponse`.
8. Personnalisez votre fichier de réponse. Vous pouvez trouver le mien dans ce repo git (mot de passe d'Administrateur : `p@ssword1234`) ou vous pouvez trouver de la documentation ici : https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/automate-windows-setup ou https://www.windowscentral.com/how-create-unattended-media-do-automated-installation-windows-10 .
9. Sauvegardez votre fichier de réponse en `autounattend.xml` et placez-le dans `MSMGT > DVD`.
10. Fermez l'Assistant Gestion d'installation et supprimez le fichier `MSMGT > DVD > sources > Install_Windows XXX.clg`, ou vous pouvez simplement le déplacer ailleurs pour éviter de le reconstruire.

#### Script CMD Setup Complete
1. Naviguez à `MSMG > DVD > sources`.
2. Créez les dossiers `$OEM > $$ > Setup > Files` et `$OEM > $$ > Setup > Scripts`.
3. Créez un nouveau fichier `SetupComplete.cmd` dans le dossier `Scripts`.
4. Remplissez-le en utilisant le modèle suivant :
```bat
@echo off
<VOTRE_COMMANDE_ICI>
rd /q /s "%WINDIR%\Setup\Files"
del /q /f "%0"
```
5. Remplacez la deuxième ligne par votre commande cmd personnalisée. Je vous suggère de créer un script PowerShell dans le dossier `Files` et l'appeler en utilisant `powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass "%WINDIR%\Setup\Files\myscript.ps1"`. J'ai ajouté mon script `post.ps1` dans ce repo git. Il créée automatiquement un contrôleur de domaine et une nouvelle forêt AD, et fixe l'addresse IP. Je conseille fortement de n'utiliser ce fichier qu'en tant qu'exemple, puisque j'utilise des valeurs personnalisées pour le réseau IP et la forêt AD.

#### Ignorer l'entrée utilisateur au moment du boot
Par défaut, quand vous bootez sur l'image ISO de Windows, il vous demandera de `Press any key to boot from CD or DVD`. On peut éviter cette partie en allant dans `MSMGT > DVD > efi > microsoft > boot` et en supprimant `efisys.bin` et `cdboot.bin`, puis renommer leurs contreparties (`efisys_noprompt.bin` et `cdboot_noprompt.bin`) comme les fichiers qu'on vient de supprimer.

#### Construire le nouvel ISO
1. Ouvrez MSMGT : `MSMGT > Start.cmd` (privilèges Administrateur requis).
2. Acceptez les conditions d'utilisation en tapant `A`.
3. Construisez le nouveau fichier ISO : Allez à `Target > Make a DVD ISO Image` en tapant `6 1` et tapez le label et le nom du nouveau fichier ISO.
4. Votre fichier ISO sera dans `MSMG > ISO`.

### Personnaliser les variables Terraform
Pour modifier les valeurs par défaut, créez un fichier `.tfvars` et définissez des nouvelles valeurs de variables. Voir https://www.terraform.io/docs/language/values/variables.html.

## Déploiement
Pour déployer la VM, exécutez (aucun privilège Administrateur n'est requis)
```ps1
.\run.ps1
```

## Destruction
Pour détruire les ressources, exécutez
```ps1
.\destroy.ps1
```
