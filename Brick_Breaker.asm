_Length struct
    x dw ?
    y dw ?
_length ends
 
Pos struct
    x dw ?
    y dw ?
    len _length <0, 0>
Pos ends
 
_Range struct
    x1 dw ?
    y1 dw ?
    x2 dw ?
    y2 dw ?
_Range ends
 
.model small
.stack 100h
 
.data
    ;Delay TImer
        del_time dw 0
    ;----used for sound
        frequency dw 0
    ;;;------menupage boxes
        check_box Pos <0, 0>
        c_len EQU check_box.len
        _x dw ?
        _y dw ?
        menuPos dw 0
    ;counters
        c1 dw ?
        c2 dw ?
        c3 dw ?
        c4 dw ?
        c5 dw ?
        c6 dw ?
        c7 dw ?
        c8 dw ?
        c9 dw ?
        stack_check dw 0
        __test db "Test","$"
    ;------menu page stuff---------
        menu_txt1 db "BRICK BREAKER!","$"
        menu_txt2 db "Move up/down using Arrow Keys","$"
        _start db "START","$"
        _Instruc db "INSTRUCTION","$"
        _High db "SCORES","$"
 
    ;------Instruction page stuff---------
        insuct_txta  db "           How to Play?", "$"
        insuct_txt1 db "1) Move the Paddle using Arrow keys", "$"
        insuct_txt2 db "        <-             ->","$"
        insuct_txt3 db "   2) Press 'Esc' for Pausing","$"
        insuct_txt4 db "             The Game", "$"
        insuct_txt5 db "3) Collect falling objects to gain", "$"
        insuct_txt6 db "         Different Powers","$"
        insuct_txt7 db "  4) Clear 3 levels in 3 lives,", "$"
        insuct_txt8 db "  And try to get the Top Score!","$"
        insuct_pgn1 db "pg 1/2","$"
       
        insuct_txta2  db "       Block Information", "$"
        insuct_txt21 db "1-Hit Blocks", "$"
        insuct_txt22 db "2-Hit Blocks","$"
        insuct_txt23 db "3-Hit Blocks","$"
        insuct_txt24 db "Unbreakable Blocks", "$"
        insuct_txt25 db "Special Blocks", "$"
        insuct_txt26 db "               Powers","$"
        insuct_txt27 db "Gain Life  Multiply Ball  Special Ball", "$"
        insuct_pgn2 db "pg 2/2","$"
   
        BriksIst _length <48, 28>, <200,28>, <48,76>, <200,76>, <140,117>
           
        InstPos dw 1

    ;-------Scores page stuff-------
        scores_txt db "Scores of Last 7 Games","$"
        scores2_txt db "Name:     Level:      Score:","$"

    ;------Get Name page stuff---------
        Entername_txt db "Enter your Name: ","$"
        playername db 25 dup ("$")
   
    ;-----play page stuff-------
        Choose_levels db "Choose Levels","$"
        _lev1 db "LEVEL 1","$"
        _lev2 db "LEVEL 2","$"
        _lev3 db "LEVEL 3","$"
        _SPACE db "Press Space to Start","$"
        ready_check dw 0 ;Ready check in start of game waiting for space to pressed before game starts, 0 for not ready, 1 for ready and start, 2 for just continue
        _pause db "PAUSED","$"
        _unpause db "      ","$"
        GameMode_txt db "Lives:         Level:        Score:","$"
        Score dw 0
        currentlevel dw 1
        printout dw 0
        alpha db 0
        beta db 0
        ;hearts
            totallives dw 3
            cls dw 65, 77, 89
            rws dw 5
            heart_lost dw 0 ;Check for heart lost, zero = no heart lost, 1 = heart lost
 
        ;Paddle
            barPos _Length <120, 175>
            barPosO _Length <120, 175>
            bar_length dw 60
   
        ;Ball
            _Diff_ Pos <-20, 20> ;Difference between starting coords of ball and paddle (Used in NotReady Proc)
            __ballspeed dw 14 ;higher value, slower ball
            ball_Pos Pos <140, 155> ;Ball Position
            initial Pos <140, 155> ;initial Position of ball stored, to reset ball Position after live lost
            ball_color dw 14
            ;Movement Checks (1 for up right, 2 for down left, 0 if game lost and stop)
                UpDown dw 1
                RightLeft dw 2
   
        ;Bricks
        Brick_color db 3 ;BLUE
        _Bricks1 _length <25,30>, <65,30>, <105,30>, <145,30>, <185,30>, <225,30>, <265,30>
                _length <15,50>, <55,50>, <95,50>, <135,50>, <175,50>, <215,50>, <255,50>
                _length <25,70>, <65,70>, <105,70>, <145,70>, <185,70>, <225,70>, <265,70>
       
        _Bricks2 _length <10,30>, <50,30>, <90,30>, <142, 30>, <195,30>, <235,30>, <275,30>
                _length <10,50>, <50,50>, <90,50>, <142, 50>, <195,50>, <235,50>, <275,50>
                _length <10,70>, <50,70>, <90,70>, <142, 70>, <195,70>, <235,70>, <275,70>
       
        _Bricks3 _length <15,30>, <55,30>, <95,30>, <135,30>, <175,30>, <215,30>, <255,30>
                _length <25,50>, <65,50>, <105,50>, <145,50>, <185,50>, <225,50>, <265,50>
                _length <15,70>, <55,70>, <95,70>, <135,70>, <175,70>, <215,70>, <255,70>
        Brick_Range _Range <>
        nB1 dw 21 ;number of bricks
        Rem_Bricks dw 21;
        Brick_check1 dw 21 dup(1)
        B_len dw 35 ;length of brick
        B_hig dw 15 ;height of brick
 
    ;-------endscreen page stuff-------
        Winscrn_txt db "Winner Winner Chicken Dinner!","$"
        Lossscrn_txt db "  Better Luck Next Time!","$"
        clsfinalscr dw 145, 155
        completerecord db 'allplays.txt', 0
        handle dw ?
        buffer db 50 dup (?), "$"
.code
 
;-------------------------------------------------------------
;-------------------------- MACROS ---------------------------
;-------------------------------------------------------------
;.
    clrc MACRO      ;clears screen
        mov ah, 0
        mov al, 13h     ;calls graphics mode and prints black box
        int 10h
        mov ah, 0BH
        mov bx, 8
        int 10h
    ENDM
   
    Print MACRO x, y, _str  ;moves cursor to specifed index
        Cursor x, y         ;then prints string over there
        mov ah, 09h
        mov bx, 0003h
        mov dx, offset _str
        int 21h
    ENDM
 
    Set MACRO A, B, x, y    ;for moving values from 2 memory index
        mov ax, x             ; to 2 other memory places
        mov bx, y
        mov A, ax
        mov B, bx
    ENDM
 
    Set2 MACRO A, B, x, y    ;for moving values from 2 memory index
        mov al, x             ; to 2 other memory places
        mov ah, y
        mov A, al
        mov B, ah
    ENDM
   
    Cursor MACRO x, y       ;moves the cursor in graphics mode to a specified point
        mov dl, x ;col (0 - 79)
        mov dh, y ;row (0 - 24)
        mov ah, 2
        int 10h
    ENDM
   
    PushTOstack MACRO val1, val2, val3, val4, val5
        mov dx, val1
        push dx             ;pushes 5 values to stack
        mov dx, val2
        push dx
        mov dx, val3
        push dx
        mov dx, val4
        push dx
        mov dx, val5
        push dx
    ENDM
   
    EmptyStack MACRO
        pop dx          ;for emptying values from stack
        pop dx
        pop dx
        pop dx
        pop dx
    ENDM
   
    Range MACRO x, y
        pusha
        mov ax, x
        mov bx, y
        mov Brick_Range.x1, ax
        mov Brick_Range.y1, bx
        add ax, B_len
        add bx, B_hig
        dec bx
        dec ax
        mov Brick_Range.x2, ax
        mov Brick_Range.y2, bx
        popa
    ENDM
 
    mov ax, @data
    mov ds, ax
    mov ax, 0
 
;-------------------------------------------------------------
;---------------------- Different Pages ----------------------
;-------------------------------------------------------------
 
Main PROC           ;the main page which is called to start game
    __Menu:
 
    clrc
        call borderterri
    call Menu       ;this proc prints the menupage
    L1:
        mov ah, 1
        int 16h
        JNZ CheckKey
    JMP L1
    CheckKey:           ;checks key which has been input and sees weather to move up or down
    mov ah, 0
    int 16h
    cmp ah, 48h
    JE hasbeenmovedup
    cmp ah, 50h
    JE hasbeenmoveddown
    cmp al, 13
    JE GOTOPAGE
    cmp al, 27
    JE __EXIT_GAME
    JMP L1
 
    hasbeenmoveddown:
    mov ax, menuPos
    cmp ax, 2       ;Compares if it already is on last most selectable option
    JE __Menu
    inc menuPos
    JMP __Menu
 
    Hasbeenmovedup:
    mov ax, menuPos
    cmp ax, 0       ;Compares if it already is on top most selected option
    JLE __Menu      ;IF so, then just goes back
    dec menuPos ;If not, it tries moving up the options
    JMP __Menu  ;Then it refreshes
   
    GOTOPAGE:
    clrc
    ;when enter pressed, check menu item selected using menuPos
    ;then which ever is == it jumps to that page
    mov ax, menuPos
    cmp ax, 0
    JE PLAY
    cmp ax, 1
    JE INSTRUCTIONS
    cmp ax, 2
    JE HIGHSCORES
    PLAY:
    call Get_Name
    call Level_Selection
    JMP __Menu        
    INSTRUCTIONS:
    call Instruction_Page
    JMP __Menu
    HIGHSCORES:
    call Scores_page
    JMP __Menu
    __EXIT_GAME:
        clrc
        mov ah, 4ch
        int 21h
        RET
Main ENDP
 
Level_Selection PROC uses ax bx cx dx
    pop bp
    push c3
    push menuPos
_Selection:
    clrc
        call borderterri
    mov _x, 105
    mov _y, 66
    mov c3, 0
    L1:
        cmp c3, 3
        JE EXIT
        Set check_box.x, check_box.y, _x, _y ;Position of Check Box
        Set c_len.x, c_len.y, 100, 20 ;Size of Check Box
        call Make_Select_Box
        mov cx, c3
        cmp cx, menuPos
        JNE continue_printing_box
        call Current_box
        continue_printing_box:
        add _y, 38
        inc c3
    JMP L1
 
    EXIT:
 
    Print 13, 3, Choose_levels
    Print 16, 9, _lev1
    Print 16, 14, _lev2
    Print 16, 19, _lev3
    L2:
        mov ah, 1
        int 16h
    JZ L2
    mov ah, 0
    int 16h
    .IF (ah == 48h)
        .IF (menuPos == 0)
            JMP L2
        .ENDIF
        dec menuPos
        JMP _Selection
    .ELSEIF (ah == 50h)
        .IF (menuPos == 2)
            JMP L2
        .ENDIF
        inc menuPos
        JMP _Selection
    .ELSEIF (al == 13)
        .IF (menuPos == 0)
            mov currentlevel, 1
        .ELSEIF (menuPos == 1)
            mov currentlevel, 2
        .ELSEIF (menuPos == 2)
            mov currentlevel, 3
        .ENDIF
        call Play_Page
    .ELSEIF (al == 27)
        JE _Return_to_Menu
    .ENDIF
    JMP L2
   
    _Return_to_Menu:
    pop menuPos
    pop c3
    push bp
    RET
Level_Selection ENDP
 
Instruction_Page PROC uses ax bx cx dx si di        ;basic dual instructions page
    instrpage:
    clrc
    call borderterri
    .IF (InstPos == 2)
        JMP instr_pg2
    .ELSE
        JMP instr_pg1
    .ENDIF
 
    instr_pg1:
        Print 3, 1, insuct_txta
        Print 3, 4, insuct_txt1
        Print 3, 6, insuct_txt2
        PushTOstack 111b, 120, 50, 5, 70
        call Full_Rect
        EmptyStack
        Print 3, 9, insuct_txt3
        Print 3, 11, insuct_txt4
        Print 3, 14, insuct_txt5
        Print 3, 16, insuct_txt6
        Print 3, 19, insuct_txt7
        Print 3, 21, insuct_txt8
        Print 0, 0, insuct_pgn1
        jmp L1
    instr_pg2:
            mov si, offset BriksIst
            mov Brick_color, 3
            call Brick
            add si, 4
            mov Brick_color, 9
            call Brick
            add si, 4
            mov Brick_color, 8
            call Brick
            add si, 4
            mov Brick_color, 0
            call Brick
            add si, 4
            call Special_Brick
            PushTOstack 4, 50, 173, 5, 5
            call Full_Rect
            EmptyStack
            PushTOstack 10, 150, 173, 5, 5
            call Full_Rect
            EmptyStack
            EmptyStack
            PushTOstack 6, 250, 173, 5, 5
            call Full_Rect
           
        Print 3, 1, insuct_txta2
        Print 3, 6, insuct_txt21
        Print 22, 6, insuct_txt22
        Print 3, 12, insuct_txt23
        Print 19, 12, insuct_txt24
        Print 13, 17, insuct_txt25
        Print 2, 20, insuct_txt26
        Print 1, 23, insuct_txt27
        Print 0, 0, insuct_pgn2
    L1:
        mov ah, 1
        int 16h
    JZ L1
    mov ah, 0
    int 16h
    .IF (al == 27)
        JMP exitif
    .ELSEIF (ah == 48h)
        .IF (InstPos == 1)
            JMP L1
        .ENDIF
        DEC InstPos
        JMP instrpage
    .ELSEIF (ah == 50h)
        .IF (InstPos == 2)
            JMP L1
        .ENDIF
        inc InstPos
        JMP instrpage
    .ELSE
        JMP L1
    .ENDIF
    exitif:
    mov Brick_color, 3
    RET
Instruction_Page ENDP
 
Scores_page PROC
    call borderterri
    Print 8, 4, scores_txt
    Print 7, 6, scores2_txt
    
    mov handle, 0
    mov ah, 3Dh
    mov dx, offset completerecord
    mov al, 0               ;0 for reading / 1 for writing
    int 21h
    mov handle, ax
    mov ah, 3FH
    mov cx, 48
    mov dx, offset buffer
    mov bx, handle
    int 21h

    Print 7, 8, buffer

    L12:
        mov ah, 1
        int 16h
    JZ L12
    mov ah, 0
    int 16h
    .IF al == 27
        JMP Resume2
    .ELSE
        JMP L12
    .ENDIF
    Resume2:
    ret
Scores_page ENDP

Get_Name PROC       ;page for getting user name
    clrc
       call borderterri
    mov si, offset playername
    Print 10, 8, Entername_txt
    Set check_box.x, check_box.y, 75, 90 ;Position of Check Box
    Set c_len.x, c_len.y, 150, 20 ;Size of Check Box
    call Make_Select_Box
   
    waitingenter:
    mov ah, 1
    int 16h
    jz waitingenter
 
    mov ah, 0
    int 16h
    cmp al, 13
    je exitwaiting    
    mov [si], al
    inc si
    mov al, '$'
    mov [si], al
    Print 10, 12, playername
    jmp waitingenter
   
    exitwaiting:
    clrc
    ret
Get_Name ENDP
 
Play_Page PROC          ; main playing page used for every ingame stuff
    pop bp
    mov score, 0
    mov totallives, 3
    mov ready_check, 0
    mov bx, nB1
    mov Rem_Bricks, bx
    mov si, offset Brick_check1
    mov cx, 1
    .WHILE (bx != 0)
        mov [si], cx
        add si, 2
        dec bx
    .ENDW
    _Play:
        .WHILE (stack_check != 0)
            pop ax
            dec stack_check
        .ENDW
        mov ax, ready_check
        .IF ax == 1
            mov ready_check, 2
        .ENDIF
        mov heart_lost, 0
    ;info on top
    printingeharts:
        clrc
        Print 1, 1, GameMode_txt
        mov cx, totallives
        mov si, offset cls
        PH:
            mov c3, cx
            push [si]
            call printheart
            pop cx
            add si, 2
            mov cx, c3
        loop PH
    ;seperation bar
        ;PushTOstack 11, 0, 20, 2, 320
        ;call Full_Rect
        ;EmptyStack
    ;-------protective side bars
        PushTOstack 111b, 0, 22, 150, 3 ;Left Verticle
        call Full_Rect
        EmptyStack
        PushTOstack 111b, 317, 22, 150, 3 ;Right Verticle
        call Full_Rect
        EmptyStack
        PushTOstack 111b, 0, 22, 3, 318 ;Upper Horizontal
        call Full_Rect
        EmptyStack
   
    ;----------use loop here for printing bricks
    .IF (currentlevel == 1)
        mov __ballSpeed, 24
        mov bar_length, 70
        mov si, offset _Bricks1
        mov ax, nB1
        mov c5, ax
        mov di, offset Brick_check1
        push si
        push ax
        push di
        add stack_check, 3
    .ELSEIF (currentlevel == 2)
        mov __ballSpeed, 19
        mov bar_length, 55
        mov si, offset _Bricks2
        mov ax, nB1
        mov c5, ax
        mov di, offset Brick_check1
        push ax
        mov ax, 2
        .IF (totallives == 3)
            mov [di + 2], ax
            mov [di + 6], ax
            mov [di + 10], ax
            mov [di + 16], ax
            mov [di + 20], ax
            mov [di + 24], ax
            mov [di + 30], ax
            mov [di + 34], ax
            mov [di + 38], ax
        .ENDIF
        pop ax
        push si
        push ax
        push di
        add stack_check, 3
    .ELSEIF (currentlevel == 3)
        mov __ballSpeed, 15
        mov bar_length, 40
        mov si, offset _Bricks3
        mov ax, nB1
        mov c5, ax
        mov di, offset Brick_check1
        push cx
        push bx
        push ax
        mov ax, 1
        mov bx, 5
        mov cx, 3
        .IF (totallives == 3)
            mov Rem_Bricks, 19
            mov [di], ax
            mov [di + 2], ax
            mov [di + 4], cx
            mov [di + 6], cx
            mov [di + 8], cx
            mov [di + 10], ax
            mov [di + 12], ax
            mov ax, 2
            mov [di + 14], ax
            mov [di + 16], bx
            mov [di + 18], cx
            mov ax, 4
            mov [di + 20], ax
            mov ax, 2
            mov [di + 22], cx
            mov [di + 24], bx
            mov [di + 26], ax
 
            mov [di + 28], ax
            mov [di + 30], ax
            mov [di + 32], cx
            mov [di + 34], cx
            mov [di + 36], cx
            mov [di + 38], ax
            mov [di + 40], ax
        .ENDIF
        pop ax
        pop bx
        pop cx
        push si
        push ax
        push di
        add stack_check, 3
    .ENDIF
    mov cl, Brick_color
    .WHILE ax != 0
        push bx
        mov bx, [di]
        .IF (bx == 5)
            mov cl, Brick_color
            mov Brick_color, 8
        .ELSEIF (bx == 4)
            mov cl, Brick_color
            call Special_Brick
        .ELSEIF (bx == 3)
            mov cl, Brick_color
            mov Brick_color, 0
        .ELSEIF (bx == 2)
            mov cl, Brick_color
            mov Brick_color, 9
        .ELSEIF (bx == 1)
            mov Brick_color, cl
        .ENDIF
        .IF (bx != 0 && bx != 4)
            call Brick
        .ENDIF
        mov Brick_color, cl
        pop bx
        dec ax
        add di, 2
        add si, 4
    .ENDW
 
    _PaddleMovement:
        ;----------- printing a paddle in black to hide its trail
        PushTOstack 000, barPosO.x, barPosO.y, 5, bar_length
        call Full_Rect
        EmptyStack
        ;printing the new paddle at the new location
        PushTOstack 111b, barPos.x, barPos.y, 5, bar_length
        call Full_Rect
        EmptyStack
   
 
    pop di
    pop c5
    pop si
    push si
    push c5
    push di
    add stack_check, 3
    M1:
        Set2 alpha, beta, 22, 1
        mov ax, currentlevel
        mov printout, ax
        call DO_OUTPUT
        Set2 alpha, beta, 36, 1
        mov ax, Score
        mov printout, ax
        call DO_OUTPUT
        mov ax, __ballSpeed
        mov del_time, ax ;Ball Speed
        mov ax, 0
        call Ball
        mov ah, 1
        int 16h
        JNZ CheckKey1
        mov ax, ready_check
        .IF ax == 0
            call NotReady
            JMP M1
        .ELSEIF ax == 1
            JMP _Play
        .ENDIF
        call delay
        call RemPrevBall
        call Move_Ball
        .IF totallives == 0
            JMP GAME_OVER
        .ENDIF
        .IF Rem_Bricks == 0
            JMP GAME_OVER
        .ENDIF
        mov ax, heart_lost
        .IF ax == 1
            mov frequency, 1500
            mov del_time, 300
            call SoundProducer
            mov frequency, 3000
            mov del_time, 400
            call SoundProducer
            mov ready_check, 0
            JMP printingeharts
        .ENDIF
 
        dec c5
        add si, 4
        add di, 2
        .IF c5 == 0
            pop di
            pop c5
            pop si
            sub stack_check, 3
            push si
            push c5
            push di
            add stack_check, 3
        .ENDIF
    JMP M1
 
    CheckKey1:
    mov ax, barPos.y
    mov barPosO.y, ax
    mov ax, barPos.x
    mov barPosO.x, ax
    mov ah, 0
    int 16h
    .IF al == 32
        mov ready_check, 1
        JMP M1
    .ENDIF
 
    cmp ah, 4bh
        JE movedleft
    cmp ah, 4dh
        JE movedright
    .IF (al == 'p' || al == 'P')
        call Pause
        .IF (al == 27)
            JMP ReturnToMenu
        .ENDIF
        Print 16, 12, _unpause
        JMP _PaddleMovement
    .ELSEIF (al == 27)
        JMP ReturnToMenu
    .ENDIF
    jmp M1
 
    movedleft:
    mov ax, barPos.x
    cmp ax, 0
    JE M1
        sub barPos.x, 5
    JMP _PaddleMovement
 
    movedright:
    mov ax, barPos.x
    push bx
    mov bx, 320
    sub bx, bar_length
    cmp ax, bx
    pop bx
    JE M1
        add barPos.x,5
    JMP _PaddleMovement
    GAME_OVER:
        call endingScreen
        clrc
    ReturnToMenu:
    .WHILE (stack_check != 0)
        pop ax
        dec stack_check
    .ENDW
    clrc
    push bp
    RET
Play_Page ENDP
 
Pause PROC uses ax bx cx dx        ;an endless loop waiting for some key to be pressed
    Print 16, 12, _pause
    L1:
        mov ah, 1
        int 16h
        JNZ CheckKey
    JMP L1
    CheckKey:
    mov ah, 0
    int 16h
    .IF (al == 'p' || al == 'P')
        JMP Resume
    .ELSEIF al == 27
        JMP Resume
    .ELSE
        JMP L1
    .ENDIF
    Resume:
    RET
Pause ENDP
 
endingScreen PROC uses ax bx cx dx si di
    pop bp
    clrc
        call borderterri
 
        Print 7, 9, playername
 
        Set2 alpha, beta, 20, 9
        mov ax, currentlevel
        mov printout, ax
        call DO_OUTPUT
        Set2 alpha, beta, 27, 9
        mov ax, Score
        mov printout, ax
        call DO_OUTPUT
 
    .IF totallives == 0      
        Print 6, 4, Lossscrn_txt
        mov si, offset clsfinalscr
        mov rws, 50
        push [si]
        call printheart
        pop cx
        mov frequency, 1500
        mov del_time, 250
        call SoundProducer
        mov frequency, 2000
        mov del_time, 250
        call SoundProducer
        mov frequency, 2750
        mov del_time, 300
        call SoundProducer
    .ELSE
        Print 6, 4, Winscrn_txt
        call drawtrophy
        mov frequency, 1750
        mov del_time, 150
        call SoundProducer
        mov frequency, 1250
        mov del_time, 150
        call SoundProducer
        mov del_time, 10
        call delay
        mov frequency, 1750
        mov del_time, 150
        call SoundProducer
        mov frequency, 1000
        mov del_time, 150
        call SoundProducer
        mov del_time, 10
        call delay
        mov frequency, 1250
        mov del_time, 150
        call SoundProducer
        mov frequency, 950
        mov del_time, 150
        call SoundProducer
    .ENDIF
 
    mov si, offset buffer
    mov ax, 10
    mov [si], ax    
    inc si
    mov ax, 13
    mov [si], ax
 
 
    mov di, offset playername
    mov c8, 10
    .WHILE c8 > 0
        mov ax, [di]
        mov [si], ax
        inc si
        inc di
        dec c8
    .ENDW
 
    mov cx, 2
    .WHILE cx != 0
        inc si
        mov ax, " "
        mov [si], ax
        dec cx
    .ENDW
   
    inc si
    mov ax, currentlevel
    add ax, 48
    mov [si], ax
 
    mov cx, 4
    .WHILE cx != 0
        inc si
        mov ax, " "
        mov [si], ax
        dec cx
    .ENDW
 
    mov ax, score
    mov bx, 10
    mov c7, 0
    .WHILE ax != 0
        div bl
        mov cl, ah
        mov ah, 0
        push cx
        inc c7
    .ENDW
    
    .WHILE c7 != 0
        inc si
        pop ax
        add ax, 48
        mov [si], ax
        dec c7
    .ENDW
    
    inc si
    mov ax, " "
    mov [si], ax

    mov si, offset buffer
    mov c7, 25
    .WHILE c7 != 0
        mov ax, "$"
        .IF ax == [si]
            mov ax, " "
            mov [si], ax
        .ENDIF
        inc si
        dec c7
    .ENDW

    ;----opening existing file
    mov handle, 0
    mov ah, 3Dh
    mov dx, offset completerecord
    mov al, 1               ;0 for reading / 1 for writing
    int 21h
    mov handle, ax
 
    mov cx,0
    mov dx, 0
    mov bx, handle
    mov ah,42h
    mov al, 2 ; 0 beginning of file, 2 end of file
    int 21h
 
    mov ah, 40h
    mov bx, handle
    mov cx, 25              ; number of characters in msg
    mov dx, offset buffer   ; msg is the thing to write into file
    int 21h
 
    mov ah, 3Eh
    mov bx, handle
    int 21h
 
    waitingenteragain:
    mov ah, 1
    int 16h
    jz waitingenteragain
    mov ah, 0
    int 16h
    cmp al, 13
    jne waitingenteragain
    clrc
    pop bp
    ret
endingScreen ENDP
 
;-------------------------------------------------------------
;---------- Other Procedures / Functions used ----------------
;-------------------------------------------------------------
 
Full_Rect PROC          ; draws a rectangle using stack!
    push bp
    mov bp, sp
 
    mov al, [bp+12]
    mov ah, 0ch
    mov cx, [bp+10]
    mov dx, [bp+8]
    mov c5, cx
    mov cx, [bp+6]
    Rows_print:
        mov c2, cx
        mov cx, c5
        mov c4, cx
        mov cx, [bp+4]
        mov c1, cx
        looptop_:
            mov c1, cx
            mov cx, c4
            int 10h
            inc cx
            mov c4, cx
            mov cx, c1
        loop looptop_
        inc dx
        mov cx, c2
    loop Rows_print
    pop bp
    RET
Full_Rect ENDP
 
delay proc uses ax bx cx dx si di        
    cmp del_time, 0
    je Del_EXIT
 
    mov si, 0
    Del:
        mov cx, 2000
        loop $
        inc si
        mov dx, del_time
        cmp si, dx
        jle Del
    Del_EXIT:
    ret
delay endp
 
Menu PROC
    push c3
    mov totallives, 3
    mov _x, 105
    mov _y, 110
    mov c3, 0
    L1:
        cmp c3, 3
        JE EXIT
        Set check_box.x, check_box.y, _x, _y ;Position of Check Box
        Set c_len.x, c_len.y, 100, 20 ;Size of Check Box
        call Make_Select_Box
        mov cx, c3
        cmp cx, menuPos
        JNE continue_printing_box
        call Current_box
        continue_printing_box:
        add _y, 25
        inc c3
    JMP L1
 
    EXIT:
 
    Print 13, 2, menu_txt1
    Print 6, 5, menu_txt2
    Print 17, 15, _start
    Print 14, 18, _Instruc
    Print 16, 21, _High
    pop c3
    RET
Menu ENDP
 
drawtrophy PROC
    PushTOstack 14, 110, 100, 30, 80
    call Full_Rect
    EmptyStack
    PushTOstack 0, 112, 102, 26, 76
    call Full_Rect
    EmptyStack
    PushTOstack 14, 125, 90, 57, 50
    call Full_Rect
    EmptyStack
    PushTOstack 14, 142, 135, 35, 15
    call Full_Rect
    EmptyStack
    PushTOstack 14, 125, 170, 10, 50
    call Full_Rect
    EmptyStack
    ret
drawtrophy ENDP
 
Current_box PROC
    pop bp
   
    mov ax, c_len.x
    mov c1, ax
    mov ax, c_len.y
    mov c2, ax
 
    mov dx, check_box.y
    L1:;UPPER HORIZONTAL
        mov cx, check_box.x
        mov ax, c_len.x
        mov c1, ax
        cmp c2, 0
        JE EXIT_L1
        L2:
            cmp c1, 0
            JE EXIT_L2
            mov ah, 0CH
            mov al, 011
            int 10h
            inc cx
            dec c1
        JMP L2
        EXIT_L2:
        inc dx
        dec c2
    JMP L1
    EXIT_L1:
 
    push bp
    ret
Current_box ENDP
 
Make_Select_Box PROC
    pop bp
 
    mov ax, c_len.x
    mov c1, ax
    mov ax, c_len.y
    mov c2, ax
 
    mov ah, 0CH
    mov al, 011
 
    mov cx, check_box.x
    mov dx, check_box.y
    L1:;UPPER HORIZONTAL
        cmp c1, 0
        JE EXIT_L1
        int 10h
        inc cx
        dec c1
    JMP L1
    EXIT_L1:
   
    L2:;RIGHT VERTICLE
        cmp c2, 0
        JE EXIT_L2
        int 10h
        inc dx
        dec c2
    JMP L2
    EXIT_L2:
 
    L3:;BOTTOM HORIZONTAL
        mov bx, c_len.x
        cmp c1, bx
        JE EXIT_L3
        int 10h
        dec cx
        inc c1
    JMP L3
    EXIT_L3:
 
    L4:;RIGHT VERTICLE
        mov bx, c_len.y
        cmp c2, bx
        JE EXIT_L4
        int 10h
        dec dx
        inc c2
    JMP L4
    EXIT_L4:
 
    push bp
    RET
Make_Select_Box ENDP
 
printheart PROC
    push bp
    mov bp, sp
    add bp, 4
    MOV AL, 100b
    MOV AH, 0CH  
    mov c1, 0
    mov c2, 0
    L11:
        mov bx, c2
        cmp bx, 5
        je exit11
        mov cx, [bp]    
        MOV DX, rws    
        INT 10H
        inc rws
        mov dx, [bp]
        dec dx
        mov [bp], dx
        inc c2
    loop L11
    exit11:
    mov c1,0
    L3:
        mov bx, c1
        cmp bx, 5
        je exit3
        mov cx, [bp]    
        MOV DX, rws    
        INT 10H
        dec rws
        mov dx, [bp]
        dec dx
        mov [bp], dx
        inc c1
        loop L3
    exit3:
    mov c1,0
    L5:
        mov bx, c1
        cmp bx, 5
        je exit5
        mov cx, [bp]    
        MOV DX, rws    
        INT 10H
        inc rws
        inc c1
    loop L5
    exit5:
    mov c1,0
    L2:
        mov bx, c1
        cmp bx, 5
        je exit2
        mov cx, [bp]  
        MOV DX, rws
        INT 10H
        inc rws
        mov dx, [bp]
        inc dx
        mov [bp], dx
        inc c1
    loop L2
    exit2:
    mov c1,0
    mov c2,0
    L6:
        mov bx, c2
        cmp bx, 5
        je exit6
        mov cx, [bp]    
        MOV DX, rws
        INT 10H
        dec rws
        mov dx, [bp]
        inc dx
        mov [bp], dx
        inc c2
    loop L6
    exit6:
    mov c1,0
    L4:
        mov bx, c1
        cmp bx, 5
        je exit4
        mov cx, [bp]    
        MOV DX, rws
        INT 10H
        dec rws
        inc c1
    loop L4
    exit4:
 
    mov rws, 5
    pop bp
    RET
printheart ENDP
 
Ball PROC uses ax bx cx dx
    pop bp
 
    mov bh, 0
_Make_Ball:
    mov ah, 0CH
    mov al, byte ptr ball_color
 
    mov c1, 7
    mov dx, ball_Pos.y
 
    L1:
        cmp c1, 0
        mov cx, ball_Pos.x
        JE EXIT_L1
        mov c2, 7
        L2:
            cmp c2, 0
            JE EXIT_L2
            int 10H
            inc cx
            dec c2
        JMP L2
        EXIT_L2:
        dec c1
        inc dx
    JMP L1
    EXIT_L1:
 
    push bp
    RET
Ball ENDP
 
RemPrevBall PROC uses ax bx cx dx
    pop bp
    mov ax, ball_color
    mov ball_color, 0
    call Ball
    mov ball_color, ax
 
    push bp
    RET
RemPrevBall ENDP
 
Move_Ball PROC uses ax bx cx dx si di
    pop bp
    mov ah, 0DH
    mov cx, ball_Pos.x
    mov dx, ball_Pos.y
    dec dx
    int 10h
    ;BRICK COLLISION
 
Collision_For_Bricks:
    mov bl, al
    add cx, 6
    int 10h
    mov bh, al
;comparing for bottom of bricks
    .IF bl == 1 || bh == 1
        .IF (currentlevel == 1)
            mov si, offset _Bricks1
        .ELSEIF (currentlevel == 2)
            mov si, offset _Bricks2
        .ELSEIF (currentlevel == 3)
            mov si, offset _Bricks3
        .ENDIF
        mov di, offset Brick_check1
        push nB1
        pop c1
        .WHILE (c1 != 0)
            Range [si], [si + 2]
            .IF (dx == Brick_Range.y2)
                push dx
                mov dx, [di]
                .IF (dx == 5)
                    JMP SKIP1
                .ENDIF
                mov dx, cx
                sub dx, 6
                .IF (cx >= Brick_Range.x1 && cx <= Brick_Range.x2) || (dx >= Brick_Range.x1 && dx <= Brick_Range.x2)
                    mov frequency, 1500
                    mov del_time, 50
                    call SoundProducer
                    push ax
                    mov ax, [di]
                    dec ax
                    mov [di], ax
                    .IF (ax == 0)
                        add score, 5
                        call BrickBroken
                        dec Rem_Bricks
                    .ELSEIF (ax == 1)
                        call Brick
                    .ELSEIF (ax == 2)
                        push dx
                        mov dl, Brick_color
                        mov Brick_color, 9
                        call Brick
                        mov Brick_color, dl
                        pop dx
                    .ELSEIF (ax == 3)
                        dec Rem_Bricks
                        call BrickBroken
                        push dx
                        push ax
                        mov ax, 0
                        mov [di], ax
                        mov ax, si
                        mov dx, di
                        push si
                        push di
                        mov si, ax
                        mov di, dx
                        mov c9, 11
                        mov c8, 5
                        .WHILE c8 != 0 && c9 != 10
                            .IF (c9 >= 21)
                                mov si, offset _Bricks3
                                mov di, offset Brick_check1
                                mov c9, 0
                            .ENDIF
                            mov dx, [di]
                            .IF (dx != 0 && dx <= 3)
                                mov dx, 0
                                mov [di], dx
                                dec Rem_Bricks
                                call BrickBroken
                                add score, 5
                                dec c8
                            .ENDIF
                            add c9, 2
                            add di, 4
                            add si, 8
                        .ENDW
                        pop di
                        pop si
                        pop ax
                        pop dx
                    .ENDIF
                    pop ax
                .ENDIF
                SKIP1:
                pop dx
            .ENDIF
            add si, 4
            add di, 2
            dec c1
        .ENDW
        _BREAK1:
        mov UpDown, 2
    .ENDIF
;Comparing for Top of Bricks
    mov ah, 0Dh
    mov cx, ball_Pos.x
    mov dx, ball_Pos.y
    add dx, 7
    int 10H
    mov bl, al
    add cx, 6
    int 10H
    mov bh, al
    .IF bl == 11 || bh == 11
        .IF (currentlevel == 1)
            mov si, offset _Bricks1
        .ELSEIF (currentlevel == 2)
            mov si, offset _Bricks2
        .ELSEIF (currentlevel == 3)
            mov si, offset _Bricks3
        .ENDIF
        mov di, offset Brick_check1
        push nB1
        pop c1
        .WHILE (c1 != 0)
            Range [si], [si + 2]
            .IF (dx == Brick_Range.y1)
                push dx
                mov dx, [di]
                .IF (dx == 5)
                    JMP SKIP2
                .ENDIF
                mov dx, cx
                sub dx, 6
                .IF (cx >= Brick_Range.x1 && cx <= Brick_Range.x2) || (dx >= Brick_Range.x1 && dx <= Brick_Range.x2)
                    mov frequency, 1500
                    mov del_time, 50
                    call SoundProducer
                    push ax
                    mov ax, [di]
                    dec ax
                    mov [di], ax
                    .IF (ax == 0)
                        add score, 5
                        dec Rem_Bricks
                        call BrickBroken
                    .ELSEIF (ax == 1)
                        call Brick
                    .ELSEIF (ax == 2)
                        push dx
                        mov dl, Brick_color
                        mov Brick_color, 9
                        call Brick
                        mov Brick_color, dl
                        pop dx
                    .ELSEIF (ax == 3)
                        dec Rem_Bricks
                        call BrickBroken
                        push dx
                        push ax
                        mov ax, 0
                        mov [di], ax
                        mov ax, si
                        mov dx, di
                        push si
                        push di
                        mov si, ax
                        mov di, dx
                        mov c9, 11
                        mov c8, 5
                        .WHILE c8 != 0 && c9 != 10
                            .IF (c9 >= 21)
                                mov si, offset _Bricks3
                                mov di, offset Brick_check1
                                mov c9, 0
                            .ENDIF
                            mov dx, [di]
                            .IF (dx != 0 && dx <= 3)
                                mov dx, 0
                                mov [di], dx
                                dec Rem_Bricks
                                call BrickBroken
                                add score, 5
                                dec c8
                            .ENDIF
                            add c9, 2
                            add di, 4
                            add si, 8
                        .ENDW
                        pop di
                        pop si
                        pop ax
                        pop dx
                    .ENDIF
                    pop ax
                .ENDIF
                SKIP2:
                pop dx
            .ENDIF
            add si, 4
            add di, 2
            dec c1
        .ENDW
        _BREAK2:
        mov UpDown, 1
    .ENDIF
_RIGHTLEFTBRICKS:
;Comparing for Right of Bricks
    mov ah, 0Dh
    mov cx, ball_Pos.x
    mov dx, ball_Pos.y
    dec cx
    int 10h
    mov bl, al
    add dx, 6
    int 10h
    mov bh, al
    .IF (bl == 1 || bh == 1)
        .IF (currentlevel == 1)
            mov si, offset _Bricks1
        .ELSEIF (currentlevel == 2)
            mov si, offset _Bricks2
        .ELSEIF (currentlevel == 3)
            mov si, offset _Bricks3
        .ENDIF
        mov di, offset Brick_check1
        push nB1
        pop c1
        .WHILE (c1 != 0)
            Range [si], [si + 2]
            .IF (cx == Brick_Range.x2)
                push cx
                mov cx, [di]
                .IF (cx == 5)
                    JMP SKIP3
                .ENDIF
                mov cx, dx
                sub cx, 6
                .IF (cx >= Brick_Range.y1 && cx <= Brick_Range.y2) || (dx >= Brick_Range.y1 && dx <= Brick_Range.y2)
                    mov frequency, 1500
                    mov del_time, 50
                    call SoundProducer
                    push ax
                    mov ax, [di]
                    dec ax
                    mov [di], ax
                    .IF (ax == 0)
                        add score, 5
                        dec Rem_Bricks
                        call BrickBroken
                    .ELSEIF (ax == 1)
                        call Brick
                    .ELSEIF (ax == 2)
                        push dx
                        mov dl, Brick_color
                        mov Brick_color, 9
                        call Brick
                        mov Brick_color, dl
                        pop dx
                    .ELSEIF (ax == 3)
                        dec Rem_Bricks
                        call BrickBroken
                        push dx
                        push ax
                        mov ax, 0
                        mov [di], ax
                        mov ax, si
                        mov dx, di
                        push si
                        push di
                        mov si, ax
                        mov di, dx
                        mov c9, 11
                        mov c8, 5
                        .WHILE c8 != 0 && c9 != 10
                            .IF (c9 >= 21)
                                mov si, offset _Bricks3
                                mov di, offset Brick_check1
                                mov c9, 0
                            .ENDIF
                            mov dx, [di]
                            .IF (dx != 0 && dx <= 3)
                                mov dx, 0
                                mov [di], dx
                                dec Rem_Bricks
                                call BrickBroken
                                add score, 5
                                dec c8
                            .ENDIF
                            add c9, 2
                            add di, 4
                            add si, 8
                        .ENDW
                        pop di
                        pop si
                        pop ax
                        pop dx
                    .ENDIF
                    pop ax
                .ENDIF
                SKIP3:
                pop cx
            .ENDIF
            add si, 4
            add di, 2
            dec c1
        .ENDW
        _BREAK3:
        mov RightLeft, 1
    .ENDIF
 
;Comparing for left of bricks
    mov ah, 0Dh
    mov cx, ball_Pos.x
    mov dx, ball_Pos.y
    add cx, 7
    int 10h
    mov bl, al
    add dx, 6
    int 10h
    mov bh, al
    .IF bl == 11 || bh == 11
        .IF (currentlevel == 1)
            mov si, offset _Bricks1
        .ELSEIF (currentlevel == 2)
            mov si, offset _Bricks2
        .ELSEIF (currentlevel == 3)
            mov si, offset _Bricks3
        .ENDIF
        mov di, offset Brick_check1
        push nB1
        pop c1
        .WHILE (c1 != 0)
            Range [si], [si + 2]
            .IF (cx == Brick_Range.x1)
                push cx
                mov cx, [di]
                .IF (cx == 5)
                    JMP SKIP4
                .ENDIF
                mov cx, dx
                sub cx, 6
                .IF (cx >= Brick_Range.y1 && cx <= Brick_Range.y2) || (dx >= Brick_Range.y1 && dx <= Brick_Range.y2)
                    mov frequency, 1500
                    mov del_time, 50
                    call SoundProducer
                    push ax
                    mov ax, [di]
                    dec ax
                    mov [di], ax
                    .IF (ax == 0)
                        add score, 5
                        dec Rem_Bricks
                        call BrickBroken
                    .ELSEIF (ax == 1)
                        call Brick
                    .ELSEIF (ax == 2)
                        push dx
                        mov dl, Brick_color
                        mov Brick_color, 9
                        call Brick
                        mov Brick_color, dl
                        pop dx
                    .ELSEIF (ax == 3)
                        dec Rem_Bricks
                        call BrickBroken
                        push dx
                        push ax
                        mov ax, 0
                        mov [di], ax
                        mov ax, si
                        mov dx, di
                        push si
                        push di
                        mov si, ax
                        mov di, dx
                        mov c9, 11
                        mov c8, 5
                        .WHILE c8 != 0 && c9 != 10
                            .IF (c9 >= 21)
                                mov si, offset _Bricks3
                                mov di, offset Brick_check1
                                mov c9, 0
                            .ENDIF
                            mov dx, [di]
                            .IF (dx != 0 && dx <= 3)
                                mov dx, 0
                                mov [di], dx
                                dec Rem_Bricks
                                call BrickBroken
                                add score, 5
                                dec c8
                            .ENDIF
                            add c9, 2
                            add di, 4
                            add si, 8
                        .ENDW
                        pop di
                        pop si
                        pop ax
                        pop dx
                    .ENDIF
                    pop ax
                .ENDIF
                SKIP4:
                pop cx
            .ENDIF
            add si, 4
            add di, 2
            dec c1
        .ENDW
        _BREAK4:
        mov RightLeft, 2
    .ENDIF
 
    mov ah, 0DH
    mov cx, ball_Pos.x
    mov dx, ball_Pos.y
 
    ;BRICK COLLISION END
    mov cx, ball_Pos.x
    mov dx, ball_Pos.y
    add dx, 7
    int 10h
    mov bl, al
    add cx, 6
    int 10h
    mov bh, al
    cmp ball_Pos.y, 25
    JE _SwitchToDown
    ;FOR PADDLE
    .IF bl == 111b || bh == 111b
        JMP _SwitchToUp
    .ENDIF
    ;;;;
_Horizontal_Check:
    mov ax, barPos.y
    sub ax, 2
    cmp ball_Pos.x, 3
    JE _SwitchToRight
    cmp ball_Pos.x, 310
    JE _SwitchToLeft
    JMP _Continue
_SwitchToDown:
    mov UpDown, 2
    JMP _Horizontal_Check
_SwitchToUp:
    mov UpDown, 1
    JMP _Horizontal_Check
_SwitchToRight:
    mov RightLeft, 1
    JMP _Continue
_SwitchToLeft:
    mov RightLeft, 2
 
_Continue:
    ;1 for up 2 for down
    cmp UpDown, 1
    JE _MoveUp
    cmp UpDown, 2
    JE _MoveDown
 
    ;1 for right 2 for left
Check_RightLeft:
    cmp RightLeft, 1
    JE _MoveRight
    cmp RightLeft, 2
    JE _MoveLeft
 
_MoveUp:
    dec ball_Pos.y
    JMP Check_RightLeft
_MoveDown:
    inc ball_Pos.y
    JMP Check_RightLeft
_MoveRight:
    inc ball_Pos.x
    JMP _CheckLost
_MoveLeft:
    dec ball_Pos.x
_CheckLost:
    mov ax, ball_Pos.y
    .IF ax > 195
        dec totallives
        mov ax, initial.x
        mov bx, initial.y
        mov ball_Pos.x, ax
        mov ball_Pos.y, bx
        mov heart_lost, 1
        mov RightLeft, 1
        mov UpDown, 1
    .ENDIF
    push bp
    RET
Move_Ball ENDP
 
DO_OUTPUT PROC uses ax bx cx dx si di
    pop bp
    push c7
    Cursor alpha, beta
 
    mov c7, 0
    mov dx, 0
    mov ax, printout
    mov bx, 10
    L3:
        mov dx, 0
        cmp ax, 0
        JE DISP
        div bx
        mov cx, dx
        push cx
        inc c7
        mov ah, 0
        JMP L3
 
    DISP:
        cmp c7, 0
        JE EXIT2
        POP DX
        ADD DX, 48
        MOV AH, 02h
        int 21h
        dec c7
        JMP DISP
 
    EXIT2:
    pop c7
    push bp
    RET
DO_OUTPUT ENDP
 
NotReady PROC uses ax bx cx dx ;wait for user to press space before starting game
    Print 10, 12, _SPACE
    mov ax, barPos.x
    mov bx, barPos.y
    sub ax, _Diff_.x
    sub bx, _Diff_.y
   
    call RemPrevBall
    mov del_time, 50
    mov ball_Pos.x, ax
    mov ball_Pos.y, bx
    RET
NotReady ENDP
 
Brick PROC uses ax bx cx dx di
    pop bp
    push c1
    push c2
    mov cx, [si]
    mov dx, [si + 2]
    mov ax, B_hig
    mov c2, ax
    L1:
        mov cx, [si]
        mov ax, B_len
        mov c1, ax
        cmp c2, 0
        JE EXIT_L1
        L2:
            .IF c2 == 15 || c1 == 35
                mov bl, 11   ;top and left of brick
            .ELSEIF c2 == 1 || c1 == 1
                mov bl, 1   ;bottom and right of brick
            .ELSE
                mov bl, Brick_color
            .ENDIF
            cmp c1, 0
            JE EXIT_L2
            mov ah, 0CH
            mov al, bl
            int 10h
            inc cx
            dec c1
        JMP L2
        EXIT_L2:
        inc dx
        dec c2
    JMP L1
    EXIT_L1:
    pop c2
    pop c1
    push bp
    Ret
Brick ENDP
 
Special_Brick PROC uses ax bx cx dx di
    pop bp
    push c1
    push c2
    mov cx, [si]
    mov dx, [si + 2]
    mov ax, B_hig
    mov c2, ax
    L1:
        mov cx, [si]
        mov ax, B_len
        mov c1, ax
        cmp c2, 0
        JE EXIT_L1
        L2:
            .IF c2 == 15 || c1 == 35
                mov bl, 11   ;top and left of brick
                mov al, bl
            .ELSEIF c2 == 1 || c1 == 1
                mov bl, 1   ;bottom and right of brick
                mov al, bl
            .ELSE
                mov al, Brick_color
            .ENDIF
            cmp c1, 0
            JE EXIT_L2
            mov ah, 0CH
            int 10h
            add Brick_color, 1
            .IF (Brick_color > 15)
                mov Brick_color, 1
            .ENDIF
            inc cx
            dec c1
        JMP L2
        EXIT_L2:
        inc dx
        dec c2
    JMP L1
    EXIT_L1:
    pop c2
    pop c1
    push bp
    mov Brick_color, 3
    Ret
Special_Brick ENDP
 
BrickBroken PROC uses ax bx cx dx di
    pop bp
    push c1
    push c2
    mov cx, [si]
    mov dx, [si + 2]
    mov ax, B_hig
    mov c2, ax
    L1:
        mov cx, [si]
        mov ax, B_len
        mov c1, ax
        inc c1
        cmp c2, 0
        JE EXIT_L1
        L2:
            cmp c1, 0
            JE EXIT_L2
            mov ah, 0CH
            mov al, 0H
            int 10h
            inc cx
            dec c1
        JMP L2
        EXIT_L2:
        inc dx
        dec c2
    JMP L1
    EXIT_L1:
    pop c2
    pop c1
    push bp
    ret
BrickBroken ENDP
 
SoundProducer PROC uses ax bx cx dx
    mov     al, 182         ; Prepare the speaker for the note
    out     43h, al
    mov     ax, frequency         ; Frequency number (in decimal) ----  increase for heavier voice
    out     42h, al         ; Output low byte.
    mov     al, ah          ; Output high byte.
    out     42h, al
    in      al, 61h
 
    ;Start the sound
    in al, 61h
    or al, 3h    ;Set bit 0 (PIT to speaker) and bit 1 (Speaker enable)
    out 61h, al
   
    call delay
   
    ;Stop the sound
    in al, 61h
    and al, 0fch    ;Clear bit 0 (PIT to speaker) and bit 1 (Speaker enable)
    out 61h, al
    ret
SoundProducer ENDP
 
borderterri PROC
    PushTOstack 11, 0, 0, 200, 3 ;Left Verticle
    call Full_Rect
    EmptyStack
    PushTOstack 11, 317, 0, 200, 3 ;Right Verticle
    call Full_Rect
    EmptyStack
    PushTOstack 11, 0, 0, 3, 318 ;Upper Horizontal
    call Full_Rect
    EmptyStack
    PushTOstack 11, 0, 197, 3, 319 ;lower Horizontal
    call Full_Rect
    EmptyStack
    ret
borderterri ENDP
end