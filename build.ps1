param (
    [Parameter(Mandatory=$true)]
    [string]$AsmFile
)

$libPath = "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.44.35207\lib\x64";
$ucrtPath = "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.26100.0\ucrt\x64";
$umPath = "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.26100.0\um\x64";
$BinDir = "bin"

if (-not (Test-Path $AsmFile)) {
    throw "File not found: $AsmFile"
}

if ([System.IO.Path]::GetExtension($AsmFile).ToLower() -ne ".asm") {
    throw "Input file must have .asm extension"
}

$AsmFile = Resolve-Path $AsmFile
$BaseName = [System.IO.Path]::GetFileNameWithoutExtension($AsmFile)
$ObjFile = "$BinDir\$BaseName.obj"
$ExeFile = "$BinDir\$BaseName.exe"

$dir = "bin"
if (Test-Path $dir) {
    Remove-Item "$BinDir\*" -Recurse -Force
} else {
    New-Item -ItemType Directory -Path $dir
}

nasm -f win64 $AsmFile -o $ObjFile
link $ObjFile `
    /SUBSYSTEM:CONSOLE `
    /DEFAULTLIB:"$umPath\kernel32.Lib" `
    /DEFAULTLIB:"$libPath\msvcrt.lib" `
    "$libPath\legacy_stdio_definitions.lib" `
    "$libPath\legacy_stdio_wide_specifiers.lib" `
    "$ucrtPath\ucrt.lib" `
    /ENTRY:main `
    /NOLOGO `
    /merge:.CRT=.rdata `
    /OUT:$ExeFile

if ($LASTEXITCODE -ne 0) { throw "LINK failed" }

Write-Output $ExeFile
# /OPT:REF `
# /OPT:ICF `
# /RELEASE `