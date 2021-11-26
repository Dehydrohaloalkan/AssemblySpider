
;section '.persEn' code readable executable

proc DrawPers uses esi edi, hDC

    invoke CreateSolidBrush, PERS_BCK_COLOR
    push eax
    invoke FillRect, [hDC], RectPers, eax
    pop eax
    invoke DeleteObject, eax

    push [font.lfHeight]
    mov [font.lfHeight], PERS_FONT
    stdcall CopyStr, font.lfFaceName, _persfont

    invoke SetTextAlign, [hDC], TA_CENTER + TA_TOP
    invoke SetBkMode, [hDC], TRANSPARENT
    invoke CreateFontIndirect, font
    invoke SelectObject, [hDC], eax
    push eax

        mov eax, PERS_X
        shr eax, 1
        mov edx, PERS_INDENT
        shr edx, 1
        invoke TextOut, [hDC], eax, edx, _persstr, 22

    pop eax
    invoke SelectObject, [hDC], eax
    invoke DeleteObject, eax

    pop [font.lfHeight]
    stdcall CopyStr, font.lfFaceName, _fontname

    mov esi, PERS_INDENT
    mov edi, PERS_INDENT + PERS_FONT
    push [BackCardIndex] [CardWigth] [CardHeight]
    mov [BackCardIndex], 0
    mov [CardWigth], CARD_RESOLUTION_X
    mov [CardHeight], CARD_RESOLUTION_Y

    .startloop1:

        stdcall GetTextureCardIndex, 10h
        stdcall DrawCard, [hDC], esi, edi

        add esi, CARD_RESOLUTION_X + PERS_INDENT
        cmp esi, PERS_X
        jne .continue

            mov esi, PERS_INDENT
            add edi, CARD_RESOLUTION_Y + PERS_INDENT

        .continue:

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
    mov ecx, CARD_RESOLUTION_X + PERS_INDENT
    div ecx
    mov [XIndex], eax

    mov eax, [YPos]
    sub eax, PERS_FONT
    xor edx, edx
    mov ecx, CARD_RESOLUTION_Y + PERS_INDENT
    div ecx
    mov [YIndex], eax

    mov eax, [XIndex]
    mov edx, CARD_RESOLUTION_X + PERS_INDENT
    mul edx
    add eax, PERS_INDENT
    mov [TempRect.left], eax
    add eax, CARD_RESOLUTION_X
    mov [TempRect.right], eax

    mov eax, [YIndex]
    mov edx, CARD_RESOLUTION_Y + PERS_INDENT
    mul edx
    add eax, PERS_INDENT + PERS_FONT
    mov [TempRect.top], eax
    add eax, CARD_RESOLUTION_Y
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
