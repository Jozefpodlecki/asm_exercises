$libPath = "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.44.35207\lib\x64";
$ucrtPath = "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.26100.0\ucrt\x64";
$umPath = "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.26100.0\um\x64";

$dir = "bin"
if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir
}

nasm -f win64 src/main.asm -o bin/main.obj
link bin/main.obj `
    /SUBSYSTEM:CONSOLE `
    /DEFAULTLIB:"$umPath\kernel32.Lib" `
    /DEFAULTLIB:"$libPath\msvcrt.lib" `
    "$libPath\legacy_stdio_definitions.lib" `
    "$libPath\legacy_stdio_wide_specifiers.lib" `
    "$ucrtPath\ucrt.lib" `
    /ENTRY:main `
    /NOLOGO `
    /merge:.CRT=.rdata `
    /OUT:bin/main.exe