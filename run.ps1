param (
    [Parameter(Mandatory=$true)]
    [string]$AsmFile
)

$ErrorActionPreference = 'Stop'

$ExeFile = ./build.ps1 $AsmFile
& $ExeFile