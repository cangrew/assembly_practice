bits 64

global  _start

section   .data
    menu  db "Fibonacci Generator fib(n):", 10
          db "Enter n: ", 0
    menu_len equ $ - menu 

    result db 'fib(n) = ', 0
    result_len equ $ - result
    newline db 10,0
    
section .bss
    input_buffer resb 20
    n resq 1
    output_buffer resb 20
    
section .text

    exit:
        ; Exit statement
        mov       rax, 60
        xor       rdi, rdi
        syscall


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


    ; input is rax, output rdi
    to_str:
        mov rbx, 10
        mov rdi, output_buffer + 19
        mov byte [rdi], 0
        test rax, rax
        jz is_zero
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

    is_zero:
        dec rdi
        mov byte [rdi], '0'
    
    done_to_str:
        inc rdi
        ret


    _start:     
        ; Print menu
        mov       rax, 1
        mov       rdi, 1
        mov       rsi, menu
        mov       rdx, menu_len
        syscall

        ; Get n
        mov rax, 0
        mov rdi, 0
        mov rsi, input_buffer
        mov rdx, 20
        syscall

      
        
        ; Turn to integer

        call to_int ; outputs int to rax
        mov [n], rax

        ; Calculate n value in fib(n)
        mov rcx, [n]
        xor rax, rax
        xor rdx, rdx
        mov rax, 0 ; current -2
        mov rbx, 1 ; current -1
    loop2:
        test rcx, rcx
        jz end_loop2

        mov rdx, rax
        
        add rax, rbx

        mov rbx, rdx
        

        dec rcx
        jmp loop2
    end_loop2:

        ; mov [n], rax
        ; Get str of value
        ; mov rax, 0
        call to_str

        ; Print menu
        mov       rax, 1
        mov       rdi, 1
        mov       rsi, result
        mov       rdx, result_len
        syscall
        mov rax, 1
        mov rdi, 1
        mov rsi, output_buffer
        mov rdx, 20
        syscall
        mov       rax, 1
        mov       rdi, 1
        mov       rsi, newline
        mov       rdx, 2
        syscall
        
        ; Exit statement
        mov       rax, 60
        xor       rdi, rdi
        syscall

