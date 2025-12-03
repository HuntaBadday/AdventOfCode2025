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
    
; Do part 1
    ; Seek back to zero
    mov rdi, [fd]
    mov rsi, 0
    mov rdx, 0
    call fseek
    
    ; Reset sum variable
    xor rax, rax
    mov [sum], rax
    
.pLoop1:
    call ReadBank
    push rax
    ;call PrintLine
    call ProcessBank2   ; Should be using ProcessBankD here, but just to show
                        ; My solution I had originally I will leave this here
    add [sum], rax
    pop rax
    cmp rax, 0
    jne .pLoop1
    
    mov rdi, sumFormat1
    mov rsi, [sum]
    call printf
    
; Do part 2
    ; Seek back to zero
    mov rdi, [fd]
    mov rsi, 0
    mov rdx, 0
    call fseek
    
    ; Reset sum variable
    xor rax, rax
    mov [sum], rax
    
.pLoop2:
    call ReadBank
    push rax
    call PrintLine
    mov rdi, 12
    call ProcessBankD
    
    add [sum], rax
    pop rax
    cmp rax, 0
    jne .pLoop2
    
    mov rdi, sumFormat2
    mov rsi, [sum]
    call printf
    
    ; Clean up
    mov rdi, [fd]
    call fclose
    
    mov rdi, [lineInput]
    call free
    
    jmp exit
    
    ; An improved version of ProcessBank2 that can work with any amount of
    ; batteries
    ; Note: I should thought of this one first...
    ; rdi - Amount of batteries to turn on
ProcessBankD:
    mov rax, 0  ; Collects the digits
    mov rbx, [lineInput]    ; Pointer to array
    mov rsi, 0              ; Starting index
.numloop:
    mov dl, 0       ; Current best value
    mov rcx, [BPB]  ; How many times to count
    sub rcx, rsi    ; Count from rsi to the end, not past it
    sub rcx, rdi    ; Count up to index N-rdi+1, this leaves room for other
    add rcx, 1      ; digits at the end in case a large digit is near the end
.loop:
    mov dh, [rbx+rsi]
    inc rsi
    cmp dh, dl
    jbe .smaller
    mov dl, dh
    mov r8, rsi     ; Index of the digit right after the best one
                    ; Used for next itteration as start index
.smaller:
    loop .loop
    
    sub dl, 0x30    ; Get value from ascii digit
    movzx rcx, dl
    mov rdx, 10
    mul rdx          ; Multiply rax by 10
    add rax, rcx     ; Collect the digit
    
    mov rsi, r8     ; Get the starting index which is right after the best digit this iteration
    dec rdi
    jnz .numloop
    
    ret             ; rax contains the jolt of this bank
    
    
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
    db "BPB: %lld", 10, 0
sumFormat1:
    db "Part 1 Sum: %lld", 10, 0
sumFormat2:
    db "Part 2 Sum: %lld", 10, 0
dFormat:
    db "%lld", 10, 0