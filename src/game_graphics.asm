; Copyright 2022 Conor Mika

; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;   http://www.apache.org/licenses/LICENSE-2.0
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.

draw_ball:
    ; find coords for each corner of old ball
    mov dx, word[ball_x_loc]
    sub dx, word[ball_x_pos_velocity]
    mov word[.erase_start_x], dx
    mov dx, word[ball_y_loc]
    sub dx, word[ball_y_neg_velocity]
    mov word[.erase_start_y], dx
    mov dx, word[ball_x_loc]
    add dx, word[ball_size]
    add dx, [ball_x_neg_velocity]
    mov word[.erase_end_x], dx
    mov dx, word[ball_y_loc]
    add dx, word[ball_size]
    add dx, word[ball_y_pos_velocity]
    mov word[.erase_end_y], dx

    ; prevent from going to far left (for some reason this is not an issue with the right paddle)
    cmp word[.erase_start_x], 0xf
    jg .in_left_bound
    mov word[.erase_start_x], 0xf
    .in_left_bound:


    mov ah, 0ch
    mov al, 0000_0000b
    mov cx, [.erase_start_x]
    mov dx, [.erase_start_y]
    .el0:
        xor bh, bh
        int 10h
        inc cx
        cmp cx, word[.erase_end_x]
        jl .el0
        mov cx, word[.erase_start_x]
        inc dx
        cmp dx, word[.erase_end_y]
        jl .el0
        
    mov ah, 0ch
    mov al, 0xf
    mov cx, word[ball_x_loc]
    mov dx, word[ball_y_loc]
    .wl0:
        xor bh, bh
        int 10h
        inc cx
        mov bx, word[ball_size]
        add bx, word[ball_x_loc]
        cmp cx, bx
        jl .wl0
        mov cx, word[ball_x_loc]
        inc dx
        mov bx, word[ball_size]
        add bx, word[ball_y_loc]
        cmp dx, bx
        jl .wl0
    ret
    .erase_start_x: dw 0x00
    .erase_start_y: dw 0x00
    .erase_end_x: dw 0x00
    .erase_end_y: dw 0x00

draw_left_paddle_up:
    cmp word[left_paddle_location], 0x01   ; check if paddle is at upper limit
    jl .done                               ; if so, skip to end and dont allow movement
    ; SPEED LOOP REPEATS MOVEMENT UP BY 1 N TIMES
    push word[user_paddle_speed]           ; push speed to stack as starting point for speed loop modifier
    .nui_speed_loop:
        ; DRAW WHITE LINE ABOVE PADDLE
        mov ah, 0ch                        ; write graphics pixel 
        mov al, 0xf                        ; white pixel
        mov cx, 0xA                        ; start x at 0xA (10th pixel from the left)
        mov dx, word[left_paddle_location] ; put temp of left_paddle_location for editing later
        .nui_0:
            xor bh, bh           ; set page to 0
            int 10h              ; VGA interrupt (write pixel)
            inc cx               ; move x location right one pixel
            cmp cx, 0xF          ; check if at full width
            jl .nui_0            ; if not at full width repeat

        ; OVERWRITE BOTTOM LINE OF PADDLE BLACK
        mov al, 0x0                        ; set color black
        mov cx, 0xA                        ; start x at 0xA (10th pixel from left)
        mov dx, word[left_paddle_location] ; put temp of left_paddle_location for editing later
        add dx, word[paddle_size]          ; get location of bottom of paddle by adding size to temp 
        .nui_1:
            xor bh, bh           ; set page to 0
            int 10h              ; VGA interrupt (write pixel)
            inc cx               ; move x location right one pixel
            cmp cx, 0xF          ; check if at full width
            jl .nui_1            ; if not at full width repeat
        dec word[left_paddle_location]     ; lower paddle location (moves it up on the screen)
        pop bx                             ; get speed loop index
        cmp bx, 0x00                       ; check if speed index at zero yet
        jle .done                          ; if it is jump to end
        dec bx                             ; lower speed loop index by one
        push bx                            ; put speed loop index back on stack
        jmp .nui_speed_loop                ; repeat speed loop
        .done:
            ret

draw_left_paddle_down:
    mov dx, 0x01E0                     ; lower limit
    sub dx, [paddle_size]              ; subtract paddle size to get lower limit for top of paddle
    cmp word[left_paddle_location], dx ; check if paddle is at lower limit
    jg .done                           ; if so, skip to end and dont allow movement
    ; SPEED LOOP REPEATS MOVEMENT DOWN BY 1 N TIMES
    push word[user_paddle_speed]       ; push speed to stack as starting point for speed loop modifier
    .ndi_speed_loop:
        ; OVERWRITE TOP LINE OF PADDLE BLACK
        mov ah, 0ch                        ; write graphics pixel
        mov al, 0x0                        ; black pixel
        mov cx, 0xA                        ; start x at 0xA (10th pixel from the left)
        mov dx, word[left_paddle_location] ; put temp of left_paddle_location for editing later
        .ndi_0:
            xor bh, bh           ; set page to 0
            int 10h              ; VGA interrupt (write pixel)
            inc cx               ; move x location right one pixel
            cmp cx, 0xF          ; check if at full width
            jl .ndi_0            ; if not at full width repeat
        
        ; DRAW WHITE LINE ABOVE PADDLE  
        mov al, 0xf                        ; white pixel
        mov cx, 0xA                        ; start x at 0xA (10th pixel from left)
        mov dx, word[left_paddle_location] ; put temp of left_paddle_location for editing later
        add dx, word[paddle_size]          ; get location of bottom of paddle by adding size to temp 
        .ndi_1:
            xor bh, bh           ; set page to 0
            int 10h              ; VGA interrupt (write pixel)
            inc cx               ; move x location right one pixel
            cmp cx, 0xF          ; check if at full width
            jl .ndi_1            ; if not at full width repeat
        inc word[left_paddle_location]     ; lower paddle location (moves it up on the screen)
        pop bx                             ; get speed loop index
        cmp bx, 0x00                       ; check if speed index at zero yet
        jle .done                          ; if it is jump to end
        dec bx                             ; lower speed loop index by one
        push bx                            ; put speed loop index back on stack
        jmp .ndi_speed_loop                ; repeat speed loop
        .done:
            ret

draw_left_paddle:
    mov ah, 0ch                             ; write graphics pixel
    mov al, 0xf                             ; white pixel
    mov cx, 0xA                             ; start x at 0xA (10th pixel from the left)
    mov dx, word[left_paddle_location]      ; start y at left_paddle_location
    .l0:
        xor bh, bh                          ; page zero
        int 10h                             ; write pixel
        inc cx                              ; move x location right one
        cmp cx, 0xF                         ; check if at full width
        jl .l0                              ; if not at full width repeat
        mov cx, 0xA                         ; reset width to starting point 
        inc dx                              ; move to the next line
        mov bx, word[paddle_size]           ; create temp paddle_size
        add bx, word[left_paddle_location]  ; add left_paddle_location to temp paddle_size
                                            ; to get the position of the bottom of the
                                            ; left paddle
        cmp dx, bx                          ; check if at bottom of paddle
        jl .l0                              ; if not, repeat
    ret

draw_right_paddle:
    mov ah, 0ch                             ; write graphics pixel
    mov al, 0xf                             ; white pixel
    mov cx, 0x276                           ; start x at 0x276 (10th pixel from the right)
    mov dx, word[right_paddle_location]     ; start y at right_paddle_location
    .l0:
        xor bh, bh                          ; page zero
        int 10h                             ; write pixel
        inc cx                              ; move x location right one
        cmp cx, 0x27B                       ; check if at full width
        jl .l0                              ; if not at full width repeat
        mov cx, 0x276                       ; reset width to starting point 
        inc dx                              ; move to the next line
        mov bx, word[paddle_size]           ; create temp paddle_size
        add bx, word[right_paddle_location] ; add right_paddle_location to temp paddle_size
                                            ; to get the position of the bottom of the
                                            ; right paddle
        cmp dx, bx                          ; check if at bottom of paddle
        jl .l0                              ; if not, repeat
    ret
