; Autor reseni: Matyas Strelec xstrel03

; Projekt 2 - INP 2022
; Vernamova sifra na architekture MIPS64

; DATA SEGMENT
                .data
login:          .asciiz "xstrel03"  ; sem doplnte vas login
code1:          .word 115   ; s
code2:          .word 116   ; t
cipher:         .space  17  ; misto pro zapis sifrovaneho loginu

params_sys5:    .space  8   ; misto pro ulozeni adresy pocatku
                            ; retezce pro vypis pomoci syscall 5
                            ; (viz nize "funkce" print_string)

;xstrel03-r28-r3-r7-r20-r0-r4
; r28   - character to be encrypted
; r20   - code
; r3    - index of character
; r4    - help register for under/overflow check
; r7    - help register for checking if not number
; r0    - 0
.text
main:
                daddi r3, r0, 0
loop:
                ; CODE 1 -> +s
                ; load character
                lb r28, login(r3)
                ; check if character is number
                daddi r7, r0, 96
                dsub r7, r7, r28
                ; if it is not, end
                bgez r7, end
                ; otherwise, continue
                ; load code
                lb r20, code1(r0)
                ; subtract 'a' = 97 and add 1
                daddi r20, r20, -96
                ; encrypt character with code
                dadd r28, r28, r20
                ; check if character is greater than 'z'
                daddi r4, r0, -123
                dadd r4, r4, r28
                ; if so, subtract 26
                bgez r4, overflow_1
                ; otherwise, continue
continue_1:
                ; store encrypted character
                sb r28, cipher(r3)
                ; increment index
                daddi r3, r3, 1

                ; CODE 2 -> -t
                ; load character
                lb r28, login(r3)
                ; check if character is number
                daddi r7, r0, 96
                dsub r7, r7, r28
                ; if it is not, end
                bgez r7, end
                ; otherwise, continue
                ; load code
                lb r20, code2(r0)
                ; subtract 'a' = 97 and add 1
                daddi r20, r20, -96
                ; negate code
                dsub r20, r0, r20
                ; encrypt character with code
                dadd r28, r28, r20
                ; check if character is less than 'a'
                daddi r4, r0, 97
                dsub r4, r4, r28
                ; if so, add 26
                bgez r4, overflow_2
                ; otherwise, continue
continue_2:
                ; store encrypted character
                sb r28, cipher(r3)
                ; increment index
                daddi r3, r3, 1
                j loop

overflow_1:
                ; subtract 26
                daddi r28, r28, -26
                ; jump to continue
                j continue_1

overflow_2:
                ; add 26
                daddi r28, r28, 26
                ; continue
                j continue_2

end:            
                ; print cipher
                daddi   r4, r0, cipher
                jal     print_string

                syscall 0   ; halt

print_string:   ; adresa retezce se ocekava v r4
                sw      r4, params_sys5(r0)
                daddi   r14, r0, params_sys5    ; adr pro syscall 5 musi do r14
                syscall 5   ; systemova procedura - vypis retezce na terminal
                jr      r31 ; return - r31 je urcen na return address
