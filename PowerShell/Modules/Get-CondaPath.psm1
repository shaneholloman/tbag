# Copyright (C) 2023 TroubleChute (Wesley Pyburn)
# Licensed under the GNU General Public License v3.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.gnu.org/licenses/gpl-3.0.en.html
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#    
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#    
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# ----------------------------------------
# These functions are useful for using conda commands in a system that you don't know where Conda is installed.
# Without running the Conda hook, you won't be able to use Conda commands - As long as it's not globally activated/available always.
# Usually you'll see (Conda) before the path in the command line, assuming it's already active.
# ----------------------------------------

<# 
.SYNOPSIS
Get the Conda PowerShell hook script path.

.DESCRIPTION
The Get-CondaPath function searches for the Conda PowerShell hook script in the specified paths and returns the path if found.

.EXAMPLE
$condaPath = Get-CondaPath

.NOTES
This function currently checks the following locations for the Conda PowerShell hook script:

1. C:\ProgramData\anaconda3\shell\condabin\conda-hook.ps1
2. C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Anaconda3 (64-bit)\Anaconda Powershell Prompt.lnk
#>
function Get-CondaPath {
    # Check if the first file exists
    $filePath1 = "C:\ProgramData\anaconda3\shell\condabin\conda-hook.ps1"
    if (Test-Path $filePath1) {
        return $filePath1
    }

    # Check if the shortcut file exists in the start menu
    $filePath2 = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Anaconda3 (64-bit)\Anaconda Powershell Prompt.lnk"

    # TODO: Check user path as well for user only installs

    if (Test-Path $filePath2) {
        # Read the target of the .lnk file
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($filePath2)
        $targetPath = $shortcut.Arguments

        # Extract the ps1 script path
        $regex = "'.+\.ps1'"
        if ($targetPath -match $regex) {
            $ps1ScriptPath = $Matches[0].Trim("'")

            # Return script path
            return $ps1ScriptPath
        }
    }
    return ""
}

<#
.SYNOPSIS
Opens the Conda environment if found.

.DESCRIPTION
The Open-Conda function calls the Get-CondaPath function to retrieve the Conda PowerShell hook script path and executes the script if found.

.EXAMPLE
Open-Conda

.NOTES
This function requires the Get-CondaPath function.
#>
function Open-Conda {
    $condaPath = Get-CondaPath
    if ($condaPath) {
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; &$condaPath
        Write-Host "Conda found!"
    }
    Catch {
        Write-Host "Failed to check if Conda is installed."
    }
}