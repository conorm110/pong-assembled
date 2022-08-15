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

ball_physics:
    .collision:
        top_and_bottom_collision:
            cmp word[ball_y_loc], 0x0001 ; highest allowed ball position
            jl .top                      ; if at or above top, trigger top collision
            cmp word[ball_y_loc], 0x01d6 ; lowest allowed ball position
            jg .bot                      ; if at or below bottom, trigger bottom collision
            jmp .done                    ; otherwise skip top and bottom collision
            .top:
                mov dx, word[ball_y_pos_velocity]  ; save old y_pos_velocity
                mov word[ball_y_pos_velocity], 0   ; dont allow ball to continue up
                mov word[ball_y_neg_velocity], dx  ; put old y_pos into y_neg
                jmp .done
            .bot:
                mov dx, word[ball_y_neg_velocity]  ; save old y_neg_velocity
                mov word[ball_y_neg_velocity], 0   ; dont allow ball to continue down
                mov word[ball_y_pos_velocity], dx  ; put old y_neg into y_pos
            .done:

        left_wall_collision:
            cmp word[ball_x_loc], 0x10          ; leftmost possible ball position
            jg .done                            ; if not at wall, skip collision
            mov dx, word[left_paddle_location]  ; create temp left_paddle_location in dx
            sub dx, 0x06                        ; position of ball starts at top left corner,
                                                ;   add 6 so that it allows partial collisions
                                                ;   (top of paddle hits bottom of ball)
            cmp word[ball_y_loc], dx            ; check if ball is above paddle when at left wall
            jl game_loss                        ; if so, you lose!
            add dx, [paddle_size]               ; add paddle size to position to get bottom of
                                                ;   paddle position
            add dx, 0x06                        ; allow partial collisions
            cmp word[ball_y_loc], dx            ; check if ball is below paddle at left wall
            jg game_loss                        ; if so, you lose!
            mov dx, word[ball_x_neg_velocity]   ; save x_neg_velocity
            mov word[ball_x_pos_velocity], dx   ; put x_neg in x_pos
            mov word[ball_x_neg_velocity], 0    ; set x_neg to zero to prevent from going left
            .done:

        right_wall_collision:
            cmp word[ball_x_loc], 0x26B         ; rightmost possible ball location
            jle .done                           ; if not at wall, skip collision
            mov dx, word[right_paddle_location] ; create temp of right_paddle_location in dx
            add dx, 0x06                        ; position of ball starts at top left corner,
                                                ;   add 6 so that it allows partial collisions
                                                ;   (top of paddle hits bottom of ball)
            cmp word[ball_y_loc], dx            ; check if ball is above paddle when at right wall
            jl game_won                         ; if so, you win!
            add dx, [paddle_size]               ; add paddle size to position to get bottom of
                                                ;   paddle position
            add dx, 0x06                        ; allow partial collisions
            cmp word[ball_y_loc], dx            ; check if ball is below paddle at right wall
            jg game_won                         ; if so, you win!
            mov dx, word[ball_x_pos_velocity]   ; save x_pos velocity]
            mov word[ball_x_pos_velocity], 0    ; set x_pos to zero to prevent from going right   
            mov word[ball_x_neg_velocity], dx   ; put old x_pos into x_neg
            .done:

    .motion:         
        cmp word[ball_x_neg_velocity], 0x0      ; check if ball is moving left
        jg .move_left                           ; if so, jump to move left action
        cmp word[ball_x_pos_velocity], 0x0      ; check if ball is moving right
        jg .move_right                          ; if so, jump to move right action
        .move_left:
            mov ax, word[ball_x_neg_velocity]   ; create temp of ball_x_neg
            sub word[ball_x_loc], ax            ; x = x - v since v is negative
            jmp .done_x_movement                ; jump to y movement
        .move_right:
            mov ax,word[ball_x_pos_velocity]    ; create temp of ball_x_pos
            add word[ball_x_loc], ax            ; x = x + v since v is positive
        .done_x_movement:
        cmp word[ball_y_neg_velocity], 0x0      ; check if ball is moving down
        jg .move_down                           ; if so, jump to move down action
        cmp word[ball_y_pos_velocity], 0x0      ; check if ball is moving up
        jg .move_up                             ; if so, jump to move up action
        .move_down:
            mov ax, word[ball_y_neg_velocity]   ; create temp of y_neg_v
            add word[ball_y_loc], ax            ; y = y + v since v is negative AND the axis is 
                                                ; inverted (lowest y is highest value)
            jmp .done_y_movement                ; jump to end
        .move_up:
            mov ax, word[ball_y_pos_velocity]   ; create temp of y_pos_v
            sub word[ball_y_loc], ax            ; y = y - v since v is pos & axis is inverted
        .done_y_movement:
    
    ret