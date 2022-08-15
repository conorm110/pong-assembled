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

computer_player:
    mov dx, word[right_paddle_location]   ; make temp of right_paddle_location for use later
    add dx, 0x37                          ; add 0x37 to temp to get middle y of paddle
    cmp dx, word[ball_y_loc]              ; compare middle of paddle to ball location
    jle .move_right_paddle_down           ; move paddle down if below
    jmp .move_right_paddle_up             ; otherwise move paddle up

    .move_right_paddle_up:
        cmp word[right_paddle_location], 0x01  ; check if paddle is at upper limit
        jl .done                               ; if so, skip to end and dont allow movement
        push word[comp_paddle_speed]           ; push speed to stack as starting point for speed loop modifier
        .rpu_speed_loop:
            ; DRAW WHITE LINE ABOVE PADDLE
            mov ah, 0ch                         ; write pixel
            mov al, 0xf                         ; white pixel
            mov cx, 0x276                       ; start x at 0x276 (10th pixel from the right)
            mov dx, word[right_paddle_location] ; put temp of right_paddle_location for editing
            .rpu_0:
                xor bh, bh    ; set page to 0
                int 10h       ; VGA interrupt (write pixel)
                inc cx        ; move x location right one pixel
                cmp cx, 0x27B ; check if at full width
                jl .rpu_0     ; if not at full width repeat

            ; OVERWRITE TOP LINE OF PADDLE BLACK
            mov al, 0x0                          ; black pixel
            mov cx, 0x276                        ; start x at 0x276 (10th pixel from the right)
            mov dx, word[right_paddle_location]  ; put temp of right_paddle_location for editing
            add dx, word[paddle_size]            ; get location of bottom of paddle by adding size to temp 
            .rpu_1:
                xor bh, bh    ; set page to 0
                int 10h       ; VGA interrupt (write pixel)
                inc cx        ; move x location right one pixel
                cmp cx, 0x27B ; check if at full width
                jl .rpu_1     ; if not at full width repeat
            dec word[right_paddle_location]      ; lower paddle location (moves it up on the screen)
            pop bx                               ; get speed loop index
            cmp bx, 0x00                         ; check if speed index at zero yet
            jle .done                            ; if it is jump to end
            dec bx                               ; lower speed loop index by one
            push bx                              ; put speed loop index back on stack
            jmp .rpu_speed_loop                  ; repeat speed loop
    .move_right_paddle_down:
        mov dx, 0x01E0                      ; lower limit
        sub dx, [paddle_size]               ; subtract paddle size to get lower limit for top of paddle
        cmp word[right_paddle_location], dx ; check if paddle is at lower limit
        jg .done                            ; if so, skip to end and dont allow movement
        push word[comp_paddle_speed]        ; push speed to stack as starting point for speed loop modifier
        .rpd_speed_loop:
            ; OVERWRITE TOP LINE OF PADDLE BLACK
            mov ah, 0ch                          ; write pixel
            mov al, 0x0                          ; black pixel
            mov cx, 0x276                        ; start x at 0x276 (10th pixel from the right)
            mov dx, word[right_paddle_location]  ; put temp of right_paddle_location for editing
            .rpd_0:
                xor bh, bh    ; set page to 0   
                int 10h       ; VGA interrupt (write pixel)
                inc cx        ; move x location right one pixel
                cmp cx, 0x27B ; check if at full width
                jl .rpd_0     ; if not at full width repeat
            ; DRAW WHITE LINE ABOVE PADDLE
            mov al, 0xf                          ; white pixel
            mov cx, 0x276                        ; start x at 0x276 (10th pixel from the right)
            mov dx, word[right_paddle_location]  ; put temp of right_paddle_location for editing
            add dx, word[paddle_size]            ; get location of bottom of paddle by adding size to temp 
            .rpd_1:
                xor bh, bh    ; set page to 0   
                int 10h       ; VGA interrupt (write pixel)
                inc cx        ; move x location right one pixel
                cmp cx, 0x27B ; check if at full width
                jl .rpd_1     ; if not at full width repeat
            inc word[right_paddle_location]      ; raise paddle location (moves it down on the screen)      
            pop bx                               ; get speed loop index
            cmp bx, 0x00                         ; check if speed index at zero yet
            jle .done                            ; if it is jump to end
            dec bx                               ; lower speed loop index by one
            push bx                              ; put speed loop index back on stack
            jmp .rpd_speed_loop                  ; repeat speed loop
    .done:
        ret