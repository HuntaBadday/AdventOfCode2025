    bits 64
    default rel
    
    global main
    
    extern fopen
    extern fclose
    extern fread
    extern fseek
    extern feof
    extern putchar
    extern getc
    extern printf
    extern malloc
    extern free
    
    section .bss
BPB:    ; Batteries per bank
    RESQ 1
fd:
    RESQ 1
    
lineInput:  ; Pointer to a line input
    RESQ 1
sum:    ; Final jolt sum
    RESQ 1
    
    section .text
main:
    ; Initialize variables
    xor rax, rax
    mov [BPB], rax
    mov [sum], rax
    
    ; Open the input file
    mov rdi, filename
    mov rsi, readMode
    call fopen
    cmp rax, 0
    je fileNotFound
    mov [fd], rax
    
    call InfoLoop
    
    xor rax, rax
    mov rdi, dbgFormat
    mov rsi, [BPB]
    call printf
    
    ; Allocate memory to read in a bank
    mov rdi, [BPB]
    call malloc
    mov [lineInput], rax
    
    mov rdi, [fd]
    mov rsi, 0
    mov rdx, 0
    call fseek
    
.pLoop:
    call ReadBank
    push rax
    call PrintLine
    call ProcessBank2
    
    add [sum], rax
    pop rax
    cmp rax, 0
    jne .pLoop
    
    mov rdi, sumFormat
    mov rsi, [sum]
    call printf
    
    ; Clean up
    mov rdi, [fd]
    call fclose
    
    mov rdi, [lineInput]
    call free
    
    jmp exit
    
PrintLine:
    mov rbx, [lineInput]
    mov rsi, 0
.loop:
    mov rdi, [rbx+rsi]
    push rbx
    push rsi
    call putchar
    pop rsi
    pop rbx
    inc rsi
    cmp rsi, [BPB]
    jne .loop
.end:
    mov rdi, 10
    call putchar
    ret
    
    ; Process a bank and get it's maximum jolt with turning on 2 batteries
ProcessBank2:
    ; First, find the biggest digit from i=0..N-2
    mov rbx, [lineInput]
    mov rsi, 0
    mov dl, 0   ; Value of current best digit
    mov rcx, [BPB]
    sub rcx, 1
.loop1:
    mov al, [rbx+rsi]
    inc rsi
    cmp al, dl
    jbe .smaller1
    mov dl, al
    mov rdi, rsi    ; Save index of best value
.smaller1:
    loop .loop1
    
    push rdx    ; Save best value
    mov dl, 0   ; Value of current best digit
    mov rcx, [BPB]
    sub rcx, rdi
.loop2:
    mov al, [rbx+rdi]
    cmp al, dl
    jbe .smaller2
    mov dl, al
.smaller2:
    inc rdi
    loop .loop2
    
    sub dl, 0x30
    
    pop rax
    sub al, 0x30
    mov bl, 10
    mul bl
    add al, dl
    movzx rax, al
    ret
    
    ; Read in a bank
    ; Return 0 in rax if EOF
ReadBank:
    mov rbx, [lineInput]
    mov rdi, 0
.loop:
    push rdi
    push rbx
    
    mov rdi, [fd]
    call feof
    cmp rax, 0
    jne .eof
    
    mov rdi, [fd]
    call getc
    
    pop rbx
    pop rdi
    
    cmp rax, 10
    je .end
    
    ;sub rax, 0x30
    mov [rbx+rdi], al
    inc rdi
    jmp .loop
    
.eof:
    pop rbx
    pop rdi
    mov rbx, 0
.end:
    mov rax, rbx
    ret
    
    ; Count the number of batteries in the first bank
InfoLoop:
    mov rdi, [fd]
    call feof
    cmp rax, 0
    jne .eof
    
    mov rdi, [fd]
    call getc
    
    cmp rax, 10
    je .end
    
    add [BPB], 1
    jmp InfoLoop
    
.eof:
    sub [BPB], 1
.end:
    ret
    
exit:
    mov rax, 0
    ret
    
fileNotFound:
    mov rax, 0x01
    mov rdi, 1
    mov rsi, fileNotFoundMsg
    mov rdx, fileNotFoundMsg.end - fileNotFoundMsg
    syscall
    jmp exit
    
    section .data
filename:
    db "input.txt", 0
readMode:
    db "r", 0
fileNotFoundMsg:
    db "File Not Found.", 10, 0
.end:

dbgFormat:
    db "BPB: %d", 10, 0
sumFormat:
    db "Sum: %d", 10, 0
dFormat:
    db "%d", 10, 0