	BITS 16

%DEFINE left_arrow 97
%DEFINE up_arrow 38
%DEFINE right_arrow 39
%DEFINE down_arrow 40
%DEFINE enter_key 13
%DEFINE backspace_key 8


start:

  mov ax, 0x07c0
  add ax, 288
  mov ss,ax
  mov sp,4096

  mov ax,0x07c0
  mov ds,ax

 ; mov ah,00h  ;Sets the screen to 80x25 16color text mode
  ;mov al,03h
  ;int 10h
  
  mov ah,03h ;Corrects the cursor attributes for any padding that might be done by qemu  
  int 10h     ;dh = row,dl = col
  


  call intro
  call draw_elements
  call main
  

  jmp $

  intro_string db 'Welcome to yeetOS',0ah
  input_string db 'TODO:reserve space for input strings and try to implement string compare :(',0ah
  
  

main:

 ;call intro
 
 mov ah,00h
 int 16h;waits for read and reads kb input and stores it on al
 
 
 cmp al,'a' ;checks input
 je cursor_left
 cmp al,'w'
 je cursor_up
 cmp al,'d'
 je cursor_right
 cmp al,'s'
 je cursor_down
 cmp al,enter_key
 je enter_input
 cmp al,backspace_key
 je backspace_input

 jmp main

cursor_left:
 
 dec dl
 mov ah,02h
 int 10h
 
 jmp main

cursor_up:

 
 dec dh
 mov ah,02h
 int 10h
 
 jmp main

cursor_right:
 
 inc dl
 mov ah,02h
 int 10h
 
 jmp main

cursor_down:
 
 inc dh
 mov ah,02h
 int 10h
 
 jmp main


enter_input:
  push dx
  mov ah,08h
  int 10h
  
  mov ah,02h
  mov dh,15
  mov dl,17
  add dl,cl
  int 10h
  
  
  mov ah,0eh
  int 10h

  
  inc cx
  pop dx
  mov ah,02h
  int 10h

 jmp main
 ret

backspace_input:
 push dx
 mov al,0

 mov ah,02h
 mov dh,15
 mov dl,17
 dec cx
 add dl,cl
 int 10h

 mov ah,0eh
 int 10h
 pop dx
 mov ah,02h
 int 10h

 jmp main


draw_elements:

 .input_elements:
  mov ch,0  ;sets up loops to draw a - u
  mov cl,0
  mov al,97
  mov ah,0eh  ;teletype output

 .rows:
  cmp al,123
  je .numbers
  cmp cl,9
  je .cols
  int 10h
  inc al
  inc cl
  inc dl  ;updates to keep cursor information aligned
 jmp .rows

 .cols:
  mov cl,0
  inc ch
  inc dh
  push ax
  mov al,0ah
  mov ah,0eh
  int 10h
  call reset_cursor
  pop ax
 jmp .rows


 .numbers:
  mov al,48
 .numbers_loop:
  cmp al,58
  je .output_screen ;all numbers have been drawn
  cmp cl,9
  je .new_line
  int 10h
  inc al
  inc cl
  inc dl
 jmp .numbers_loop

 .new_line:
  inc dh
  mov cl,0
  push ax
  mov al,0ah
  int 10h
  call reset_cursor
  pop ax
 jmp .numbers_loop


  .output_screen:;text field starts at 15;17

 ;draws top bar
  mov dh,14   ;sets coordinates of cursor with dh and dl 
  mov dl,16
  mov ah,02h  ;ah = set cursot position  
  int 10h     
  mov al,' '
  mov ah,09h  ;write char
  mov cx,16   ;number of times
  mov bl,70h  ;color spec
  int 10h 
  
  ;move to next line
  inc dh
  mov ah,02h
  int 10h 
  
  mov ah,09h
  mov cx,1
  mov bl,70h
  int 10h 

  add dl,15
  mov ah,02h
  int 10h

  mov ah,09h
  mov cx,1
  mov bl,70h
  int 10h 

  inc dh
  sub dl,15
  mov ah,02h
  int 10h
;draws the bottom bar
  mov al,' '
  mov ah,09h
  mov cx,16
  mov bl,70h
  int 10h 

  sub dh,2
  mov dl,0
  mov ah,02h
  int 10h

  mov cx,0
  
 ret


reset_cursor:;sets cursor to leftmost position
  
  mov dl,0
  mov ah,02h
  int 10h

  ret

print_string:;prints string on si
  mov ah, 0eh


.repeat:
  lodsb
  cmp al,0ah
  je .done
  int 10h
  inc dl
  jmp .repeat

.done:
  int 10h
  inc dh
  call reset_cursor  

  ret


intro:   ;Prints welcome message and requests input
  mov si,intro_string
  call print_string

  mov si,input_string
  call print_string
  mov al,0ah
  inc dh
  int 10h

  ret








times 510-($-$$) db 0
dw 0xAA55
 
  
