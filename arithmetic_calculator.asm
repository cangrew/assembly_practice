; Basic Arithmetic Calculator
bits 64

section .data
menu db 'Select an operation:', 10
     db '1. Addition', 10
     db '2. Subtraction', 10
     db '3. Multiplication', 10
     db '4. Division', 10
     db 'Enter your choice (1-4):', 0
menu_len equ $ - menu
first db 'Enter first number:'
first_len equ $ - first
second db 'Enter second number:'
second_len equ $ - second
result db 'Result = ', 0
result_len equ $ - result

choice db 0

test_str db '2', 0

newline db 10

section .bss
a    resq 1
b    resq 1
result_num resq 1
parse_buffer resb 20


global _start

section .text
    print:
        mov       rax, 1
        mov       rdi, 1
        syscall
        ret
        
    read:
        mov       rax, 0
        mov       rdi, 0
        syscall
        ret
        
    ; input is rsi
    to_int:
        xor rax, rax
    parse_loop:
        ; Load next char
        movzx rcx, byte[rsi]

        test rcx, rcx
        jz done_parsing
        cmp rcx, 10 ; ASCII value for '\n'
        je done_parsing
      
        sub cl, '0'

        imul rax, 10

        add rax, rcx

        ; Move to the next character
        inc   rsi
        jmp   parse_loop
    done_parsing:
        ret

    ; input is rax
    to_str:
        mov rbx, 10
        mov rdi, parse_buffer + 19
        mov byte [rdi], 0
    loop_to_str:
        
        test rax, rax
        jz done_to_str

        xor rdx, rdx
        div rbx

        add dl, '0'
        dec rdi
        mov [rdi], dl
        

        ; Move to the next character
        jmp   loop_to_str
    done_to_str:
        inc rdi
        ret

    
    
    _start:
        ; Write the menu to STDOUT (file descriptor 1)
        mov       rsi, menu     ; Pointer to the menu string
        mov       rdx, menu_len ; Length of the menu string
        call      print

        ; Get choice 
        mov       rsi, choice
        mov       rdx, 2
        call      read

        ; Print and read first number
        mov rsi, first
        mov rdx, first_len
        call print
        mov rsi, a
        mov rdx, 20
        call read
    
        ; Print and read second number
        mov rsi, second
        mov rdx, second_len
        call print
        mov rsi, b
        mov rdx, 1
        call read


        ; Convert ASCII to integer
        mov rsi, a
        call to_int
        mov [a], rax
        
        mov rsi, b
        call to_int
        mov [b], rax


        ; Perform the selected operation
        mov al, [choice]
        cmp al, '1'
        je addition
        cmp al, '2'
        je subtraction
        cmp al, '3'
        je multiplication
        cmp al, '4'
        je division
        
    addition:
        mov rax, [a]
        add rax, [b]
        mov [result_num], rax
        jmp print_result

    subtraction:
        mov rax, [a]
        sub rax, [b]
        mov [result_num], rax
        jmp print_result
 
    multiplication:
        mov rax, [a]
        mul byte [b]
        mov [result_num], rax
        jmp print_result

    division:
        mov rax, [a]
        mov rbx, [b]
        xor rdx, rdx
        div rbx
        mov [result_num], rax
        jmp print_result
        

    print_result:
        
        ; Convert result back to ASCII
        mov rax, [result_num]
        call to_str
        
        
        ; Print result
        mov rsi, result
        mov rdx, result_len
        call print
        mov rsi, parse_buffer
        mov rdx, 20
        call print
    
        ; Print newline
        mov rsi, newline
        mov rdx, 1
        call print

        ; Exist program
        mov       rax, 60
        xor       rdi, rdi
        syscall