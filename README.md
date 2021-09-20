# trace.moe-windows-menu

[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/search-by-trace.moe?style=flat-square)](https://www.powershellgallery.com/packages/search-by-trace.moe/)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/search-by-trace.moe?style=flat-square)](https://www.powershellgallery.com/packages/search-by-trace.moe/)

Right click images in file explorer to search on trace.moe

![](https://images.plurk.com/4mtGacxqdp1VO3dwcHmwgF.png )
![](https://images.plurk.com/4MCbCqXAw0G4rGmYsepIqc.png)

## Install
Open Windows Terminal (powershell) with administrator privileges (You'll have to enter "Y" multiple times)
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
Install-Script -Name search-by-trace.moe
search-by-trace.moe.ps1 -install
```

## Update
```powershell
Update-Script search-by-trace.moe
```

## Uninstall
```powershell
search-by-trace.moe.ps1 -uninstall
Uninstall-Script search-by-trace.moe
```
