#!/usr/bin/env pwsh
#Requires -Version 5.1

. $PSScriptRoot\lexer\Lexer.ps1

$IsPesterInstalled = $(Get-Command -Name "Invoke-Pester" -ErrorAction SilentlyContinue)

if ($null -eq $IsPesterInstalled) {
    Install-Module -Name "Pester" -Scope CurrentUser
}

Invoke-Pester