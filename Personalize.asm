
;section '.persEn' code readable executable

proc DrawPers uses esi edi, hdc

    invoke CreateSolidBrush, PERS_BCK_COLOR
    push eax
    invoke FillRect, [hdc], RectPers, eax
    pop eax
    invoke DeleteObject, eax

    push [font.lfHeight]
    mov [font.lfHeight], PERS_FONT
    stdcall CopyStr, font.lfFaceName, _persfont

    invoke SetTextAlign, [hdc], TA_CENTER + TA_TOP
    invoke SetBkMode, [hdc], TRANSPARENT
    invoke CreateFontIndirect, font
    invoke SelectObject, [hdc], eax
    push eax

        mov eax, PERS_X
        shr eax, 1
        mov edx, PERS_INDENT
        shr edx, 1
        invoke TextOut, [hdc], eax, edx, _persstr, 22

    pop eax
    invoke SelectObject, [hdc], eax
    invoke DeleteObject, eax

    pop [font.lfHeight]
    stdcall CopyStr, font.lfFaceName, _fontname

    push [BackCardIndex] [CardWigth] [CardHeight]
    mov [CardWigth], PERS_CARD_WIGTH
    mov [CardHeight], PERS_CARD_HEIGHT

    mov [PersCard + CRD_XCord], PERS_INDENT
    mov [PersCard + CRD_YCord], PERS_INDENT + PERS_FONT

    mov [BackCardIndex], 0
    mov ecx, 4
    .startloop1:
        push ecx
        stdcall Card.Close, PersCard
        stdcall Card.Draw, PersCard, [hdc]
        pop ecx

        add [PersCard + CRD_XCord], PERS_CARD_WIGTH + PERS_INDENT
        loop .skip
            mov ecx, 4
            mov [PersCard + CRD_XCord], PERS_INDENT
            add [PersCard + CRD_YCord], PERS_CARD_HEIGHT + PERS_INDENT
        .skip:

    inc [BackCardIndex]
    cmp [BackCardIndex], 12
    jne .startloop1

    pop [CardHeight] [CardWigth] [BackCardIndex]

    ret
    endp
proc FindBackCard, XPos, YPos

    locals
        XIndex  dd  ?
        YIndex  dd  ?
    endl

    cmp [YPos], PERS_FONT + PERS_INDENT
    jl .nocard

    mov eax, [XPos]
    xor edx, edx
    mov ecx, PERS_CARD_WIGTH + PERS_INDENT
    div ecx
    mov [XIndex], eax

    mov eax, [YPos]
    sub eax, PERS_FONT
    xor edx, edx
    mov ecx, PERS_CARD_HEIGHT + PERS_INDENT
    div ecx
    mov [YIndex], eax

    mov eax, [XIndex]
    mov edx, PERS_CARD_WIGTH + PERS_INDENT
    mul edx
    add eax, PERS_INDENT
    mov [TempRect.left], eax
    add eax, PERS_CARD_WIGTH
    mov [TempRect.right], eax

    mov eax, [YIndex]
    mov edx, PERS_CARD_HEIGHT + PERS_INDENT
    mul edx
    add eax, PERS_INDENT + PERS_FONT
    mov [TempRect.top], eax
    add eax, PERS_CARD_HEIGHT
    mov [TempRect.bottom], eax

    invoke PtInRect, TempRect, [XPos], [YPos]
    cmp eax, 0
    je .nocard
        mov eax, [YIndex]
        mov edx, PERS_X_COUNT
        mul edx
        mov edx, [XIndex]
        add eax, edx
        jmp .finish
    .nocard:
        mov eax, [BackCardIndex]
    .finish:
    ret
    endp
