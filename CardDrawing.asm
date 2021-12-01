
proc DrawMap, hDC

    invoke CreateCompatibleDC, [hDC]
    mov [hdcBackBuffer], eax
    invoke SelectObject, [hdcBackBuffer], [hBackBuffer]

    invoke BitBlt, [hDC], 0, 0, [RectClient.right], [RectClient.bottom], [hdcBackBuffer], 0, 0, SRCCOPY
    stdcall DrawMovingCards, [hDC]

    invoke DeleteDC, [hdcBackBuffer]

    mov eax, [SolvingDecksCount]
    cmp eax, 8
    jne .finish

        invoke SetTextAlign, [hDC], TA_CENTER + TA_BASELINE
        invoke SetBkMode, [hDC], TRANSPARENT
        mov [font.lfHeight], 300
        invoke CreateFontIndirect, font
        push eax
        invoke SelectObject, [hDC], eax

        push [winstrlen]
        push _winstr
        mov eax, [RectClient.bottom]
        shr eax, 1
        push eax
        mov eax, [RectClient.right]
        shr eax, 1
        invoke TextOut, [hDC], eax

        pop eax
        invoke DeleteObject, eax

    .finish:
    ret
    endp
proc MakeBackBuffer, hDC

    invoke CreateCompatibleDC, [hDC]
    mov [hdcBackBuffer], eax
    invoke SelectObject, [hdcBackBuffer], [hBackBuffer]

    invoke CreateSolidBrush, GAME_BCK_COLOR
    push eax
    invoke FillRect, [hdcBackBuffer], RectClient, eax

    cmp [IsGame], 0
    je .finish

        stdcall DrawSolvingDecks, [hdcBackBuffer]
        stdcall DrawNewDecks, [hdcBackBuffer]
        stdcall DrawPointCounter, [hdcBackBuffer]
        stdcall DrawStaticCards, [hdcBackBuffer]

    .finish:
    invoke DeleteDC, [hdcBackBuffer]
    pop eax
    invoke DeleteObject, eax

    ret
    endp
proc DrawMovingCards, hDC

    mov ecx, [ColumnLength + 10 * 4]
    cmp ecx, 0
    je .finish

    mov edx, 64 * 10 * 4
    .startloop1:
    push ecx edx edx
        stdcall GetTextureCardIndex, [CardInfo + edx]
        pop edx
        stdcall DrawCard, [hDC], [CardsPositionX + edx], [CardsPositionY + edx]
    pop edx ecx
    add edx, 4
    loop .startloop1

    .finish:
    ret
    endp
proc DrawStaticCards, hDC

    xor ecx, ecx
    .startloop1:
    push ecx

        mov edx, ecx
        shl edx, 2
        mov ecx, [ColumnLength + edx]
        shl edx, 6

        cmp ecx, 0
        je .emptycolmn
        .startloop2:
        push ecx edx edx
            stdcall GetTextureCardIndex, [CardInfo + edx]
            pop edx
            stdcall DrawCard, [hDC], [CardsPositionX + edx], [CardsPositionY + edx]
        pop edx ecx
        add edx, 4
        loop .startloop2
        jmp .endloop2
        .emptycolmn:
            pop ecx
            push ecx
            cmp ecx, 10
            je .endloop2
            stdcall DrawEmptyColumnRect, [hDC], edx
        .endloop2:
    pop ecx
    inc ecx
    cmp ecx, 10
    jne .startloop1

    ret
    endp
proc DrawSolvingDecks, hDC

    locals
        XPos    dd  ?
        YPos    dd  ?
    endl

    mov ecx, [SolvingDecksCount]
    cmp ecx, 0
    je .finish

    mov eax, [CenterColumnInterval]
    mov [XPos], eax

    mov eax, [RectClient.bottom]
    sub eax, [CardHeight]
    sub eax, [Indent]
    mov [YPos], eax

    xor edx, edx
    .startloop1:
    push ecx
        mov eax, [SolvingInformation + edx]
        push edx
        stdcall GetTextureCardIndex, eax
        stdcall DrawCard, [hDC], [XPos], [YPos]
        mov eax, [XPos]
        add eax, [DownInterval]
        mov [XPos], eax
        pop edx
        add edx, 4
    pop ecx
    loop .startloop1

    .finish:
    ret
    endp
proc DrawNewDecks, hDC

    locals
        XPos    dd  ?
        YPos    dd  ?
    endl

    mov ecx, [NewDecksCount]
    cmp ecx, 0
    je .finish

    mov eax, [RectClient.right]
    mov edx, [CenterColumnInterval]
    sub eax, edx
    sub eax, [CardWigth]
    mov [XPos], eax

    mov eax, [RectClient.bottom]
    sub eax, [CardHeight]
    sub eax, [Indent]
    mov [YPos], eax

    .startloop1:
    push ecx
        stdcall GetTextureCardIndex, 10h
        stdcall DrawCard, [hDC], [XPos], [YPos]
        mov eax, [XPos]
        sub eax, [DownInterval]
        mov [XPos], eax
    pop ecx
    loop .startloop1

    .finish:
    ret
    endp
proc DrawPointCounter, hDC

    invoke SetTextAlign, [hDC], TA_CENTER + TA_BOTTOM
    invoke SetBkMode, [hDC], TRANSPARENT
    invoke CreateFontIndirect, font
    push eax
    invoke SelectObject, [hDC], eax

    stdcall IntToStr, [Points], PointsStr + 8

    push [PointsStrLen]
    push PointsStr
    mov eax, [RectClient.bottom]
    sub eax, [DownInterval]
    push eax
    mov eax, [RectClient.right]
    shr eax, 1
    invoke TextOut, [hDC], eax

    pop eax
    invoke DeleteObject, eax

    ret
    endp
proc DrawCard, hDC, left, top

    locals
        hCardDC dd  ?
        Line    dd  ?
    endl

    invoke CreateCompatibleDC, [hDC]
    mov [hCardDC], eax
    invoke SelectObject, [hCardDC], [hTextures]
    mov [hTextures], eax

    mov eax, [TextureLine]
    mov edx, CARD_RESOLUTION_Y
    mul edx
    mov [Line], eax

    mov eax, [TextureIndex]
    mov edx, CARD_RESOLUTION_X
    mul edx


    invoke TransparentBlt, [hDC], [left], [top], [CardWigth], [CardHeight], \
                         [hCardDC], eax, [Line], CARD_RESOLUTION_X, CARD_RESOLUTION_Y, 00FF8080h


    invoke SelectObject, [hCardDC], [hTextures]
    mov [hTextures], eax
    invoke DeleteDC, [hCardDC]

    ret
    endp
proc DrawEmptyColumnRect, hDC, index

    locals
        hbruh   dd  ?
        hpen    dd  ?
    endl

    mov eax, GAME_BCK_COLOR
    and eax, 00B0B0B0h
    invoke CreateSolidBrush, eax
    invoke SelectObject, [hDC], eax
    mov [hbruh], eax

    invoke CreatePen, PS_SOLID, 3, 00000000h
    invoke SelectObject, [hDC], eax
    mov [hpen], eax

    push 10 10

    mov eax, [Indent]
    add eax, [CardHeight]
    push eax

    mov edx, [index]
    mov eax, [CardsPositionX + edx]
    add eax, [CardWigth]
    push eax

    push [Indent]
    push [CardsPositionX + edx]
    invoke RoundRect, [hDC]

    invoke SelectObject, [hDC], [hpen]
    invoke DeleteObject, eax
    invoke SelectObject, [hDC], [hbruh]
    invoke DeleteObject, eax

    ret
    endp
proc GetTextureCardIndex, Info

    mov eax, [Info]
    bt eax, 4
    jc .closecard

    mov edx, [Info]
    shr edx, 5
    mov [TextureLine], edx

    mov eax, [Info]
    and eax, 0Fh
    dec eax
    mov [TextureIndex], eax
    jmp .finish

    .closecard:
        mov [TextureLine], 4
        mov eax, [BackCardIndex]
        mov [TextureIndex], eax

    .finish:
    ret
    endp
