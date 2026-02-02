global main
extern CreateToolhelp32Snapshot
extern Process32First
extern Process32Next
extern CloseHandle
extern printf_s

SECTION .data
TH32CS_SNAPPROCESS equ 0x00000002
MAX_PATH equ 260

fmt db "%s", 10, 0      ; "%s\n" for printf_s

; PROCESSENTRY32 structure
; dwSize, cntUsage, th32ProcessID, th32DefaultHeapID, th32ModuleID
; cntThreads, th32ParentProcessID, pcPriClassBase, dwFlags, szExeFile[260]
PROCESSENTRY32:
    dd 0                 ; dwSize
    dd 0                 ; cntUsage
    dd 0                 ; th32ProcessID
    dq 0                 ; th32DefaultHeapID
    dd 0                 ; th32ModuleID
    dd 0                 ; cntThreads
    dd 0                 ; th32ParentProcessID
    dd 0                 ; pcPriClassBase
    dd 0                 ; dwFlags
    times MAX_PATH db 0  ; szExeFile[260]

SECTION .text
main:
    sub rsp, 40

    mov rcx, TH32CS_SNAPPROCESS ; dwFlags
    xor rdx, rdx                ; th32ProcessID = 0 (all processes)
    call CreateToolhelp32Snapshot
    mov rbx, rax                ; save snapshot handle

    lea rcx, [rel PROCESSENTRY32]
    mov dword [rcx], 568        ; sizeof(PROCESSENTRY32) = 568 bytes on x64

    lea rcx, [rel PROCESSENTRY32]
    mov rdx, rbx                 ; snapshot handle
    call Process32First
    test rax, rax
    jz .done                     ; no processes

.loop:

    mov rax, rsp
    and rsp, -16
    sub rsp, 40
    lea rcx, [rel fmt]
    lea rdx, [rel PROCESSENTRY32 + 44]
    call printf_s
    mov rsp, rax

    lea rcx, [rel PROCESSENTRY32]
    mov rdx, rbx
    call Process32Next
    test rax, rax
    jnz .loop

.done:
    mov rcx, rbx
    call CloseHandle

    add rsp, 40
    xor eax, eax
    ret