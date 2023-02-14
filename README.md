# PersistentPathStack

Pushing and popping: Navigating in PowerShell with Push-Location and Pop-Location


## Functions

Those are the 2 main functions that you will use, they replace the usual popd and pushd

- Pop-PersistentPath - popp
- Push-PersistentPath - pushp

To get the whole stack 
- Get-PersistentPaths

To add and peek, remove:

- New-PersistentPath
- Test-PersistentPath
- Remove-PersistentPath


## Push-PersistentPath details

The ```Push-PersistentPath```, replaces the ```Push-Location``` cmdlet. It pushes a location onto the location stack. The new location is now at the top of the stack. You can continue adding locations to the stack as necessary. The location is saved in the registry so that it can be used in other powershell sesions.

## Pop-PersistentPath details

The ```Pop-PersistentPath```, replaces the ```Pop-Location``` cmdlet. It pops a location onto the location stack. The new location is now at the top of the stack. You can continue adding locations to the stack as necessary. The location is saved in the registry so that it can be used in other powershell sesions.

## The difference between Push/Pop-PersistentPath and Push/Pop-Location

At first, using Push-PersistentPath and Pop-PersistentPath may seem like using the cd command to navigate to a location. To some extent, it is. However, these two cmdlets provide additional value that Push/Pop-PersistentPath does not provide.

When you use Push/Pop-PersistentPath followed by a drive path, you move to that location and the location is saved so that you can retrieve that location in another powershell session or even after a reboot. You can use Push/Pop-PersistentPath with any PSDrive. Working with the registry provider is like working with the file system provider. In this next example, use the same commands, Push-Location and Pop-Location, as before. This time, use two registry paths:

```
	# Push a location onto the stack - registry
	# First path, HKEY_LOCAL_MACHINE
	Push-PersistentPath -Path HKLM:\System\CurrentControlSet\Control\BitlockerStatus

	# Second path, HKEY_CURRENT_USER
	Push-PersistentPath -Path HKCU:\Environment\

	# Get the default location stack
	Get-PersistentPaths
```

## Stacks

Push-PersistentPath and Pop-PersistentPath can access locations in multiple ```stacks``` . By default, the stack named ***default*** is used, but you can specify anoth stack name when calling Pop/Push-PersistentPath. Similarly, you can list the PersistentPath using ```Get-PersistentPaths```

This will list all stacks names

```
    Get-PersistentPathStacks
```

This will get all values from all stacks

```
	# This will get all values from all stacks
     Get-PersistentPaths -All

     # This will get values from the stack "MyStack"
     Get-PersistentPaths -StackName MyStack
```


## Published

https://www.powershellgallery.com/packages/PowerShell.PersistentPathStack/1.0.73

![demo](https://raw.githubusercontent.com/arsscriptum/PowerShell.PersistentPathStack/main/gif/demo.gif)

![test](https://raw.githubusercontent.com/arsscriptum/PowerShell.PersistentPathStack/main/gif/test.gif)

