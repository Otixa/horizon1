# Horizon1

**Horizon1** is a LUA flight script for the game *Dual Universe* by Novaquark.  
Originally developed by the ingame organisation '*Shadow Templars*', the authors left the game but kindly
released the sources to the public in spring of 2024.

New maintainers on these repositories are working on updating the codebase to become compatible with the latest game version's LUA API.

> ❗ Horizon 1 in *master* branch is solely a **FLIGHT** script, **NOT** the elevator script!

> ❗ Branch *elevator-lua-screen* contains the elevator and screen script!

## Development

### Updates

#### 2024-04-30 *elevator-lua-screen* branch, @tobitege

* Elevator working, starts up as "Elevator v1.1.0"
* Lots of tweaks during code review.
* HUD is now on by default incl. fuel display.
* Stats display on screen was broken due to fuel display.
* If landed at startup, engines will be kept off.
* Startup code with several sanity checks (e.g. missing components).
* Added ALT+5 (open) and ALT+6 (close) for emitter to send open/close  
command on channel "door_control" (if emitter is linked).  
Manual action, no automation for it yet!
* Requires dubuild 1.0.1!
* **Installable files: /output/Elevator.json and /src/LuaScreen.lua !**

#### 2024-02-26 *elevator-lua-screen* branch, @tobitege

* Codebase revised to fix deprecated DU API calls.
* Updated this README.md file.
* Added interim "build_\*.bat" files to run builds of the 2 main lua files (adapt paths to your env!).
* Status: script starts up without LUA errors, elevator screen activates and reacts to clicks.
* Todo: currently in bugfixing mode: Set Base causes an error without error message in chat window.

## Introduction

The sections below detail various steps and methods when developing for Horizon1, along with the general style guides and principles when developing Lua code for Dual Universe.

Please take some time to familiarize yourself with the guidelines before beginning development.

Please visit the *Horizon Support* Discord server (original authors left Dual Universe, but maintainers may try to help):  
https://discord.gg/E2UEQhkzty

## General Guidelines

When developing DU Lua code, please observe the following guidelines:

- [Lua Class Guide](Class-Guidelines)
- [Horizon Module Guide](HorizonModule-Guidelines)

If you are uncertain about the correct way to implement something, you should always consult a senior member of the research department.

## Development Environment

### Visual Studio Code

If you do not already have VSCode installed, you can [download it here](https://code.visualstudio.com/download). Once downloaded, install it and either open the folder (or if it exists the `Horizon1.code-workspace` workspace file) with VSCode.

#### Setup

To be able to build Horizon1 correctly, you need to clone the Horizon1 repository from the [Horizon1 repository](https://github.com/Otixa/Horizon1/) with below command in a terminal window:  
`git clone https://github.com/Otixa/Horizon1/`

This will create in the current folder a new "Horizon1" subfolder.  

#### Extensions

* In order to build on save, you could install the [Trigger Task on Save](https://marketplace.visualstudio.com/items?itemName=Gruntfuggly.triggertaskonsave) extension.  
* If you want to have IntelliSense support you should install [Lua by sumneko](https://marketplace.visualstudio.com/items?itemName=sumneko.lua).  
* Additional recommended extensions are [vscode-lua](https://marketplace.visualstudio.com/items?itemName=trixnz.vscode-lua), [Lua](https://marketplace.visualstudio.com/items?itemName=keyring.Lua), and [Lua Debug](https://marketplace.visualstudio.com/items?itemName=actboy168.lua-debug).

## DUBuild System

This system requires to implement a structural template with a fixed name and following below rules, so that the "dubuild" application can work on it.
Please find and explore the examples in the [dubuild](https://github.com/Otixa/dubuild) repository!

### DUBuild Syntax

#### --@class

This attribute should be the first one applied in a file. It designates which *logical* class is contained within the file for DUBuild to properly assemble its dependency tree.  
It does not need to be an actual LUA class object, though, and can just include methods. The attribute "marks" this file like a bookmark so it can be referenced during the build process.

The `--@class` attribute should be followed by the class name.

Example usage:

```lua
--@class MyClass
function MyClass()
  --- ...
end
```

#### --@require

This attribute should be applied to classes that depend on other classes/utilities.

The `--@require` attribute should be followed by a _single_ class name. If you require multiple classes, you should include multiple `--@require` attributes.

Example usage:

```lua
--@class MyClass
--@require MyOtherClass
--@require YetAnotherClass

function MyClass()
  --- ...
end
```
