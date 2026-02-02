global main
extern CreateToolhelp32Snapshot
extern Process32FirstW
extern Process32NextW
extern CloseHandle
extern wprintf

SECTION .data
TH32CS_SNAPPROCESS equ 0x00000002
INVALID_HANDLE_VALUE equ -1
MAX_PATH equ 260

fmt dw 'P','I','D',':',' ','%','8','u',' ','-',' ','%','l','s',10,0  ; Wide string format

align 16
pe32:
    .dwSize:            dd 0
    .cntUsage:          dd 0
    .th32ProcessID:     dd 0
    .th32DefaultHeapID: dq 0
    .th32ModuleID:      dd 0
    .cntThreads:        dd 0
    .th32ParentProcessID: dd 0
    .pcPriClassBase:    dd 0
    .dwFlags:           dd 0
    .szExeFile:         times MAX_PATH dw 0

SECTION .text
main:
    push rbx
    push rsi
    sub rsp, 40

    ; Create snapshot
    mov ecx, TH32CS_SNAPPROCESS
    xor edx, edx
    call CreateToolhelp32Snapshot
    cmp rax, INVALID_HANDLE_VALUE
    je .error
    
    mov rbx, rax
    lea rsi, [rel pe32]
    mov dword [rsi], 568

    ; Process32FirstW
    mov rcx, rbx
    mov rdx, rsi
    call Process32FirstW
    test eax, eax
    jz .cleanup

.loop:
    lea rcx, [rel fmt]
    mov edx, [rsi + 8]   ; PID
    lea r8, [rsi + 44]   ; szExeFile
    call wprintf

    ; Process32NextW
    mov rcx, rbx
    mov rdx, rsi
    call Process32NextW
    test eax, eax
    jnz .loop

.cleanup:
    mov rcx, rbx
    call CloseHandle
    xor eax, eax
    add rsp, 40
    pop rsi
    pop rbx
    ret

.error:
    mov eax, 1
    add rsp, 40
    pop rsi
    pop rbx
    ret