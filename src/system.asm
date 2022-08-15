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

set_vga:
    mov ah, 00h ; set video mode interrupt
    mov al, 12h ; 640x480 16c VGA
    int 10h     ; VGA interrupt

set_repeat_rate:
    mov ah, 03h ; set typematic rate and dey
    mov al, 05h ; set repeat and delay rates
    mov bl, 00h ; 250 ms repeat rate
    mov bh, 00h ; 30/sec repeat rate
    int 16h     ; keyboard interrupt
    ret

single_tick_delay:
    ret


; takes int n, wait n/18.21 seconds
delay:
    pop word[.ret_ptr]   ; save return pointer
    pop word[.n]         ; put input number in variable .n
    mov ah, 00h          ; read system timer
    int 1Ah              ; time int
    add word[.n], dx     ; add current ticks to n to get ticks to return at
    .l0:
        int 1Ah          ; time int (read system timer)
        cmp word[.n], dx ; check if current ticks reached final tick
        jg .l0           ; repeat until less than or equal
    push word[.ret_ptr]  ; push return pointer back on stack
    ret
    .n dw 0x00
    .ret_ptr dw 0x00

