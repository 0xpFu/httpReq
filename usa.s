BITS 64

global _start

section .bss

    output_req resb 4096

    struc _sockaddr_in
        sin_family: resw 1
        sin_port: resw 1
        sin_addr: resd 1
    endstruc

    struc http_req
        header: resb 256
    endstruc

section .rodata

    _struct_sockaddr:
    istruc _sockaddr_in
        at sin_family, dw 0x2
        at sin_port, dw 0x5000
        at sin_addr, dd 0x43d63ad8
    iend

    _http_req:
    istruc http_req
        at header, db `GET / HTTP/1.1\r\nHost: www.google.fr\r\nUser-Agent: curl/7.55.1\r\n\r\n`
    iend

section .text

_start: 
    mov rax, 41
    mov rdi, 0x2
    mov rsi, 0x1
    mov rdx, 0x0
    syscall
    push rax
    jmp _connect

_connect:
    mov rax, 42
    pop rdi
    push rdi
    mov rsi, _struct_sockaddr
    mov rdx, 0x10
    syscall
    jmp _send_header_method
  
_send_header_method:
    mov rax, 0x1
    pop rdi
    push rdi
    mov rsi, _http_req + header
    mov rdx, 256
    syscall
    jmp _read_result

_read_result:
    mov rax, 0
    pop rdi
    mov rsi, output_req
    mov rdx, 4096
    syscall
    jmp _write_result

_write_result:
    mov rax, 1
    mov rdi, 1
    mov rsi, output_req
    mov rdx, 4096
    syscall
    jmp _exit

_exit:
    mov rax, 0x3C
    mov rdi, 0
    syscall