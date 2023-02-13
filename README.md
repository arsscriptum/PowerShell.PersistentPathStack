# PersistentPathStack

### Why ?

Reddit user [ripanarapakeka](https://www.reddit.com/user/ripanarapakeka/) was asking "Is there a way to get the full location history, across sections, akin to how (Get-PSReadLineOption).HistorySavePath stores the command history?" for paths. From [this blog post]https://www.reddit.com/r/PowerShell/comments/10wuada/get_full_pushlocation_history/)

### How 

I decided to make a saved history of path using the registry.


### Functions

Those are the 2 main functions that you will use, they replace the usual popd and pushd
- Pop-PersistentPath
- Push-PersistentPath

To get the whole stack 
- Get-PersistentPathList

To add and peek, remove:

- New-PersistentPath
- Peek-PersistentPath
- Remove-PersistentPath


## Published

https://www.powershellgallery.com/packages/PowerShell.PersistentPathStack/1.0.36