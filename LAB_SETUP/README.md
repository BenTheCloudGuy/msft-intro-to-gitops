# Setup Local/Lab Machines

Setup Local Environment..

- Create working/repo folder under user profile (permissions and best practice)
- Validate WinGet is installed to make installing easier
- Install WSL2 & Ubuntu (for later work with Linux/Docker)
- Setup Git/SSH for local system
- Setup Oh-My-Posh on Terminal
- Setup Azure CLI
- Setup Terraform
- Setup VSCode + Extensions

## Install Required Software


Validate winget is working and walk through the usage.

```powershell
PS C:\Users\benthebuilder.MSFTLABS> winget search terraform
Name                                 Id                                Version              Match              Source
---------------------------------------------------------------------------------------------------------------------
HashiCorp Terraform                  Hashicorp.Terraform               1.13.5               Moniker: terraform winget
Hashicorp Terraform Alpha            Hashicorp.Terraform.Alpha         1.10.0-alpha20240828 Moniker: terraform winget
Hashicorp Terraform Beta             Hashicorp.Terraform.Beta          1.7.0-beta2          Moniker: terraform winget
Hashicorp Terraform RC               Hashicorp.Terraform.RC            1.8.0-rc1            Moniker: terraform winget
Coder                                Coder.Coder                       2.28.0               Tag: terraform     winget
Coder Desktop (Core)                 Coder.CoderDesktop                0.8.1                Tag: terraform     winget
HashiCorp Terraform Language Server  Hashicorp.TerraformLanguageServer 0.38.2               Tag: terraform     winget
Infracost                            Infracost.Infracost               0.10.42              Tag: terraform     winget
Microsoft Azure Export for Terraform Microsoft.Azure.AztfExport        0.18.0               Tag: terraform     winget
Azure Terrafy                        Microsoft.Azure.Aztfy             0.10.0               Tag: terraform     winget
OpenTofu                             OpenTofu.Tofu.Alpha               1.8.0-alpha1         Tag: terraform     winget
btptf                                SAP.btptf                         1.4.0                Tag: terraform     winget
terraform-docs                       Terraform-docs.Terraform-docs     0.20.0               Tag: terraform     winget
TFLint                               TerraformLinters.tflint           0.59.1               Tag: terraform     winget
tenv                                 Tofuutils.Tenv                    4.7.21               Tag: terraform     winget
Terraform Switcher                   Warrensbox.TerraformSwitcher      0.13.1308            Tag: terraform     winget
spacectl                             spacelift-io.spacectl             1.15.2               Tag: terraform     winget
Terragrunt                           Gruntwork.Terragrunt              0.93.3               Tag: Terraform     winget
Terraformer                          WazeSRE.Terraformer               0.8.24                                  winget
```

### Install Powershell 7.5.x

```powershell
winget install pwsh
```

Now set Powershell 7.5.x as default for terminal

![1762789007954](image/README/1762789007954.png)

### Install AzureCLI

WInGet: ``winget install Microsoft.AzureCLI``

![1762791361350](image/README/1762791361350.png)

Close/Reopen Terminal and verify Az Install ``az --version``

![1762791626105](image/README/1762791626105.png)

### Install Teraform

WinGet: ``winget install hashicorp.terraform``

![1762791535984](image/README/1762791535984.png)

  Close / Reopen terminal and verify Terraform version

![1762791583480](image/README/1762791583480.png)

### Setup Git/SSH for Local System

Install windows based 'git' and setup SSH Key(s).

#### Setup Git4Windows

- URL: [Git - Install for Windows](https://git-scm.com/install/windows)
- WinGet: ``winget install --id Git.Git --source winget``

![1762787018900](image/README/1762787018900.png)

![1762787135944](image/README/1762787135944.png)

 During Install - installer will popup and complete.. This is expected behavior. After install completes - close and reopen 'terminal' and validate git is working..

![1762787217711](image/README/1762787217711.png)

Now configure git using --global configs!

![1762787422303](image/README/1762787422303.png)

#### Setup SSH Key

Using ssh-keygen to create key dedicated for 'Git' work.

```powershell
# Create .ssh folder under user profile
md ~/.ssh

# CD into .ssh
cd ~/.ssh

# Create Key
ssh-keygen -t rsa -b 4096 -f git_key
## leave passphrase blank by hitting enter twice ##

```

![1762787815278](image/README/1762787815278.png)

#### Configure SSH key for Azure DevOps

Open Devops in browser and click profile - ... (elipse) - User Settings

![1762790558181](image/README/1762790558181.png)

Then select "SSH Public Keys"

![1762790603376](image/README/1762790603376.png)

The click "+ New Key" and copy/paste the contents of ~/.ssh/git_key.pub to the box (see below). Recommend name key after the key on local machine so easy to match up later.

![1762790790881](image/README/1762790790881.png)

After you hit "Add" - you should see it listed in your list of keys.

![1762790852312](image/README/1762790852312.png)

#### Create SSH Config file to stream line Git/SSH experience

```powershell
# Create Config file
new-item ~/.ssh/config

# Add this to the file and save:

```

![1762791130717](image/README/1762791130717.png)

### Setup Oh-My-Posh on Terminal

* Installer: [Windows | Oh My Posh](https://ohmyposh.dev/docs/installation/windows) (Manual)
* WinGet: winget install JanDeDobbeleer.OhMyPosh --source winget
* Install Fonts: winget install DEVCOM.JetBrainsMonoNerdFont

#### Install Oh-My-Posh

![1762788292636](image/README/1762788292636.png)

#### Install Fonts

![1762788404193](image/README/1762788404193.png)

You'll see this prompt - click "YES"

![1762788430740](image/README/1762788430740.png)

#### Optional - Install Terminal Fonts

![1762788460939](image/README/1762788460939.png)

#### Configure Oh-My-POSH for Terminal

Drop down and select Settings

![1762788553634](image/README/1762788553634.png)

Under Appearence - set Font Face as "JetBrainsMono Nerd Font" and save.

![1762788779358](image/README/1762788779358.png)

#### Create .themes folder under user profile

Review available Themes: [Themes | Oh My Posh](https://ohmyposh.dev/docs/themes)

Open themes Repo for Oh-My-Posh: [oh-my-posh/themes at main · JanDeDobbeleer/oh-my-posh](https://github.com/JanDeDobbeleer/oh-my-posh/tree/main/themes) and select your desired theme and then Download as RAW file.

![1762789873416](image/README/1762789873416.png)

```powershell
# Create .themes directory
md ~/.themes

# Move paradox theme to ~/.themes directory
mv ./Downloads/paradox.omp.json ~/.themes

# Initialize and use theme 
oh-my-posh init pwsh --config "~\.themes\paradox.omp.json" | Invoke-Expression

# Set theme in profile so it loads with terminal
'oh-my-posh init pwsh --config "~\.themes\paradox.omp.json" | Invoke-Expression' >> $profile
```


### Setup Visual Studio Code

Installer: [Download Visual Studio Code - Mac, Linux, Windows](https://code.visualstudio.com/Download)

WinGet: winget install Microsoft.VisualStudioCode

![1762791840417](image/README/1762791840417.png)

Open vscode and configure terminal to use Oh-My-Posh fonts ``` > configure:

> @feature:terminal

![1762792154604](image/README/1762792154604.png)
