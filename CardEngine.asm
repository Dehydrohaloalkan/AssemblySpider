
section '.cardEn' code readable executable

proc RandomGet wMin, wMax

     mov        eax, [RandPr]
     rol        eax, 7
     add        eax, 23
     mov        [RandPr], eax

     mov        ecx, [wMax]
     sub        ecx, [wMin]
     inc        ecx
     xor        edx, edx
     div        ecx
     mov        eax, edx
     add        eax, [wMin]

     ret
     endp
proc IntToStr Num, String

    locals
        Len dd  0
    endl

    mov eax, [Num]
    mov ecx, 10
    cmp eax, 0
    jnl .calculate
        mov eax, 0

    .calculate:
        cmp eax, 0
        je .endcalculate

        xor edx, edx
        div ecx
        push edx
        inc [Len]
        jmp .calculate

    .endcalculate:

    mov ecx, [Len]
    add ecx, 8
    mov [PointsStrLen], ecx
    sub ecx, 8
    mov edx, [String]
    cmp ecx, 0
    je .endloop1
    .startloop1:

        pop eax
        add eax, '0'
        mov byte [edx], al
        inc edx

    loop .startloop1
    .endloop1:

    mov byte [edx], 0

    ret
    endp
proc CopyStr uses esi edi, Dest, Sours

    mov ecx, 35
    mov edi, [Dest]
    mov esi, [Sours]
    repnz movsb

    ret
    endp


proc SetInitArray uses esi edi, DeckCount, Seed

    xor edx, edx
    xor ecx, ecx
    mov eax, 1
    .startloop1:

        mov [edx + InitArray], eax
        shl ecx, 5
        add [edx + InitArray], ecx
        shr ecx, 5

        inc eax
        cmp eax, 14
        jne .endloop1
        mov eax, 1

        inc ecx
        cmp ecx, [DeckCount]
        jne .endloop1
        xor ecx, ecx

    .endloop1:
    add edx, 4
    cmp edx, 104*4
    jne .startloop1

    cmp [Seed], 1
    je .finish
    mov eax, [Seed]
    mov [RandPr], eax

    mov ecx, MIXER
    .startloop2:
    push ecx

        stdcall RandomGet, 0, 104
        mov edi, eax
        shl edi, 2
        push edi
        stdcall RandomGet, 0, 104
        mov esi, eax
        shl esi, 2
        pop edi

        mov eax, [InitArray + esi]
        mov edx, [InitArray + edi]
        mov [InitArray + edi], eax
        mov [InitArray + esi], edx

    pop ecx
    loop .startloop2

    .finish:
    ret
    endp
proc SetColumnsLenght

    mov edx, 10
    .startloop1:

        mov [ColumnLength + edx * 4 - 4], 5

    .finloop1:
    dec edx
    jnz .startloop1

    inc [ColumnLength + 0 * 4]
    inc [ColumnLength + 1 * 4]
    inc [ColumnLength + 2 * 4]
    inc [ColumnLength + 3 * 4]
    mov [ColumnLength + 10 * 4], 0

    ret
    endp
proc GameStart, Seed, DeckCount

    mov [IsNeedRepaint], 1
    mov [IsGame], 1
    mov [InitPt], 0
    mov [SolvingDecksCount], 0
    mov [NewDecksCount], 5
    mov [Points], 500
    mov [font.lfHeight], 55
    stdcall SetColumnsLenght
    stdcall SetInitArray, [DeckCount], [Seed]
    stdcall SetCardsStartInfo
    stdcall SetCardsIntervals
    stdcall SetCardsPositions

    ret
    endp

proc SetCardsPositions uses ebx

    locals
        VerticalInterval    dd  ?
    endl

    mov eax, [CenterColumnInterval]
    mov edx, [CardWigth]
    shr edx, 1
    sub eax, edx

    xor edx, edx
    .startloop1:
    push edx

        shl edx, 2
        mov ecx, [ColumnLength + edx]
        mov ebx, [Indent]
        shl edx, 6

        test ecx, ecx
        jz .emptycolmn
        .startloop2:

            mov [CardsPositionX + edx], eax
            mov [CardsPositionY + edx], ebx
            add ebx, [CardAfterInterval + edx]
            add edx, 4

        loop .startloop2
        jmp .endloop2
        .emptycolmn:
            mov [CardsPositionX + edx], eax
        .endloop2:
        add eax, [CenterColumnInterval]

    pop edx
    inc edx
    cmp edx, 10
    jnz .startloop1

    ret
    endp
proc SetCardsStartInfo uses esi

    mov esi, [InitPt]
    mov ecx, 10
    .startloop1:
    push ecx

        mov edx, ecx
        dec edx
        shl edx, 2
        mov ecx, [ColumnLength + edx]
        shl edx, 6

        .startloop2:

            mov eax, [InitArray + esi]
            add eax, 10h
            mov [CardInfo + edx], eax
            add edx, 4
            add esi, 4

        loop .startloop2

        mov eax, [CardInfo + edx - 4]
        sub eax, 10h
        mov [CardInfo + edx - 4], eax

    pop ecx
    loop .startloop1

    mov [InitPt], esi

    ret
    endp
proc SetMetrics

    mov eax, [RectClient.right]
    xor edx, edx
    mov ecx, 13
    div ecx
    mov [CardWigth], eax

    xor edx, edx
    mov ecx, 3
    div ecx
    shl eax, 2
    mov [CardHeight], eax

    mov eax, [RectClient.bottom]
    xor edx, edx
    mov ecx, 6
    div ecx
    cmp eax, [CardHeight]
    jg .othermetrics

    mov [CardHeight], eax

    shr eax, 2
    mov edx, 3
    mul edx
    mov [CardWigth], eax

    .othermetrics:
    mov eax, [RectClient.right]
    xor edx, edx
    mov ebx, 11
    div ebx
    mov [CenterColumnInterval], eax

    mov eax, [RectClient.bottom]
    shr eax, 5
    mov [Indent], eax

    mov eax, [CardWigth]
    shr eax, 3
    mov [DownInterval], eax

    ret
    endp
proc SetCardsIntervals

    locals
        OpenInterval    dd  ?
        CloseInterval   dd  ?
        Workspace       dd  ?
    endl

    mov ecx, 10
    .startloop1:
    push ecx

        mov edx, ecx
        dec edx
        shl edx, 2
        mov ecx, [ColumnLength + edx]
        shl edx, 6
        cmp ecx, 0
        je .endloop3

        push edx ecx

            mov eax, [CardHeight]
            shr eax, 2
            mov [OpenInterval], eax
            shr eax, 1
            mov [CloseInterval], eax

            xor edx, edx
            .startloop2:
                mov eax, [CardInfo + edx]
                add edx, 2
                bt eax, 4
                sbb edx, 0
            loop .startloop2
            add edx, 10

            push edx

                mov eax, [RectClient.bottom]
                shr eax, 2
                mov ecx, 3
                xor edx, edx
                mul ecx
                mov [Workspace], eax

                mov eax, [CloseInterval]
                pop ecx
                push ecx
                xor edx, edx
                mul ecx

                pop ecx
                cmp eax, [Workspace]
                jl .endcalculate

                mov eax, [Workspace]
                xor edx, edx
                div ecx
                mov [CloseInterval], eax
                shl eax, 1
                mov [OpenInterval], eax

        .endcalculate:
        pop ecx edx

        .startloop3:
            mov eax, [CardInfo + edx]
            bt eax, 4
            jc .closecard
                mov eax, [OpenInterval]
                mov [CardAfterInterval + edx], eax
                jmp .finloop3
            .closecard:
                mov eax, [CloseInterval]
                mov [CardAfterInterval + edx], eax
            .finloop3:
                add edx, 4
        loop .startloop3
        .endloop3:

    pop ecx
    dec ecx
    jnz .startloop1

    ret
    endp
proc CopyCards uses esi edi, Index, SoursColumn, DestColumn

    mov esi, [SoursColumn]
    shl esi, 2
    mov ecx, [ColumnLength + esi]
    sub ecx, [Index]
    sub [ColumnLength + esi], ecx
    shl esi, 6
    mov edx, [Index]
    shl edx, 2
    add esi, edx
    mov edi, [DestColumn]
    shl edi, 2
    mov edx, [ColumnLength + edi]
    add [ColumnLength + edi], ecx
    shl edx, 2
    shl edi, 6
    add edi, edx

    push ecx edi esi
    add esi, CardsPositionX
    add edi, CardsPositionX
    rep movsd
    pop esi edi ecx

    push ecx edi esi
    add esi, CardsPositionY
    add edi, CardsPositionY
    rep movsd
    pop esi edi ecx

    add esi, CardInfo
    add edi, CardInfo
    rep movsd

    ret
    endp
proc MoveCards, delX, delY

    mov ecx, [ColumnLength + 10 * 4]
    cmp ecx, 0
    je .finish
    mov edx, 64*10*4

    .startloop1:

        mov eax, [delX]
        add [CardsPositionX + edx], eax
        mov eax, [delY]
        add [CardsPositionY + edx], eax
        add edx, 4

    loop .startloop1

    .finish:
    ret
    endp
proc AddNewCards uses esi

    mov esi, [InitPt]
    mov ecx, 10
    .startloop1:

        mov edx, ecx
        dec edx
        shl edx, 2
        mov eax, [ColumnLength + edx]
        inc [ColumnLength + edx]
        shl edx, 6
        shl eax, 2
        add edx, eax

        mov eax, [InitArray + esi]
        mov [CardInfo + edx], eax
        add esi, 4

    loop .startloop1
    mov [InitPt], esi

    ret
    endp
proc CheckEmptyColums

    xor edx, edx
    .startloop1:

        mov eax, [ColumnLength + edx]
        cmp eax, 0
        je .empty

    add edx, 4
    cmp edx, 10*4
    jne .startloop1

    mov eax, 1
    jmp .finish
    .empty:
    mov eax, 0

    .finish:
    ret
    endp


proc FindCard, XPos, YPos, Index, Column

    mov eax, [XPos]
    mov edx, [CenterColumnInterval]
    shr edx, 1
    add eax, edx
    xor edx, edx
    div [CenterColumnInterval]
    dec eax
    cmp eax, -1
    je .nocard
    cmp eax, 10
    je .nocard

    mov edx, [Column]
    mov [edx], eax
    mov edx, eax
    shl edx, 2
    mov ecx, [ColumnLength + edx]
    cmp ecx, 0
    je .nocard
    shl edx, 6
    shl ecx, 2
    add edx, ecx
    shr ecx, 2
    sub edx, 4

    mov eax, [CardsPositionX + edx]
    mov [TempRect.left], eax
    add eax, [CardWigth]
    mov [TempRect.right], eax
    mov eax, [CardsPositionY + edx]
    mov [TempRect.top], eax
    add eax, [CardHeight]
    mov [TempRect.bottom], eax

    .startloop1:
    push ecx edx

        invoke PtInRect, TempRect, [XPos], [YPos]
        pop edx
        sub edx, 4
        cmp eax, 0
        jne .getinfo
        mov eax, [TempRect.top]
        sub eax, [CardAfterInterval + edx]
        mov [TempRect.top], eax

    pop ecx
    loop .startloop1
    jmp .nocard

    .getinfo:
        pop ecx
        dec ecx
        mov edx, [Index]
        mov [edx], ecx
        mov eax, 1
        jmp .finish
    .nocard:

        mov eax, [RectClient.right]
        mov edx, [CenterColumnInterval]
        sub eax, edx
        mov [TempRect.right], eax

        mov ecx, eax
        mov eax, [NewDecksCount]
        dec eax
        cmp eax, -1
        je .noNew
        cmp eax, 0
        je .onecard
            mov edx, [DownInterval]
            mul edx
            add eax, [CardWigth]
            jmp .loading
        .onecard:
            mov eax, [CardWigth]
        .loading:
        sub ecx, eax
        mov [TempRect.left], ecx

        mov eax, [RectClient.bottom]
        sub eax, [Indent]
        mov [TempRect.bottom], eax

        sub eax, [CardHeight]
        mov [TempRect.top], eax

        invoke PtInRect, TempRect, [XPos], [YPos]
        cmp eax, 0
        je .noNew

        mov eax, 2
        jmp .finish

    .noNew:
        mov eax, 0

    .finish:
    ret
    endp
proc CheckMoving uses ebx esi, Index, Column

    mov edx, [Column]
    shl edx, 2
    mov ecx, [ColumnLength + edx]
    shl ecx, 2
    shl edx, 6
    add ecx, edx
    add ecx, CardInfo
    mov eax, [Index]
    shl eax, 2
    add edx, eax
    add edx, CardInfo

    mov eax, [edx]
    bt eax, 4
    jc .canntmove

    mov eax, [edx]
    shr eax, 5
    mov esi, eax

    mov eax, [edx]
    and eax, 0Fh
    mov ebx, eax
    add edx, 4
    cmp edx, ecx
    je .canmove

    .startloop1:

        mov eax, [edx]
        and eax, 0Fh
        dec ebx
        cmp ebx, eax
        jne .canntmove

        mov eax, [edx]
        shr eax, 5
        cmp eax, esi
        jne .canntmove

    add edx, 4
    cmp edx, ecx
    jne .startloop1

    .canmove:
        mov eax, 1
        jmp .finish
    .canntmove:
        xor eax, eax
    .finish:
    ret
    endp
proc FindColumn, XPos, YPos, Column

    mov eax, [XPos]
    mov edx, [CenterColumnInterval]
    shr edx, 1
    add eax, edx
    xor edx, edx
    div [CenterColumnInterval]
    dec eax
    cmp eax, -1
    je .nocolumn
    cmp eax, 10
    je .nocolumn

    mov edx, [Column]
    mov [edx], eax
    mov eax, 1
    jmp .finish

    .nocolumn:
        mov eax, 0

    .finish:
    ret
    endp
proc CheckPlacing uses ebx, Column

    mov edx, [Column]
    shl edx, 2
    mov ecx, [ColumnLength + edx]

    cmp ecx, 0
    je .canplace

    dec ecx
    shl ecx, 2
    shl edx, 6
    add edx, ecx
    mov eax, [CardInfo + edx]
    and eax, 0Fh
    dec eax
    mov ebx, eax

    mov eax, [CardInfo + 10 * 64 * 4]
    and eax, 0Fh
    cmp ebx, eax
    jne .canntplace

    .canplace:
        mov eax, 1
        jmp .finish
    .canntplace:
        mov eax, 0
    .finish:
    ret
    endp
proc PostCheckCards

    mov ecx, 10
    .startloop1:
    push ecx

        mov edx, 10
        sub edx, ecx
        shl edx, 2
        mov eax, [ColumnLength + edx]

        cmp eax, 0
        je .endloop1

        push edx
        cmp eax, 13
        jb .opencard

        stdcall CheckSolveDeck, ecx

        .opencard:
            pop edx
            mov eax, [ColumnLength + edx]
            shl edx, 6
            dec eax
            shl eax, 2
            add edx, eax
            mov eax, [CardInfo + edx]
            bt eax, 4
            jnc .endloop1
            mov eax, [CardInfo + edx]
            sub eax, 10h
            mov [CardInfo + edx], eax

    .endloop1:
    pop ecx
    loop .startloop1

    ret
    endp
proc CheckSolveDeck uses ebx esi, Index

    shl edx, 6
    dec eax
    shl eax, 2
    add edx, eax

    mov ebx, [CardInfo + edx]
    bt ebx, 4
    jc .finish
    mov ebx, [CardInfo + edx]
    and ebx, 0Fh
    cmp ebx, 1
    jne .finish
    mov esi, [CardInfo + edx]
    shr esi, 5
    sub edx, 4

    mov ecx, 12
    .startloop1:

        mov eax, [CardInfo + edx]
        bt eax, 4
        jc .finish
        mov eax, [CardInfo + edx]
        and eax, 0Fh
        inc ebx
        cmp eax, ebx
        jne .finish
        mov eax, [CardInfo + edx]
        shr eax, 5
        cmp eax, esi
        jne .finish

        sub edx, 4

    loop .startloop1
    mov ecx, [Index]
    mov edx, 10
    sub edx, ecx
    shl edx, 2
    sub [ColumnLength + edx], 13

    mov ecx, [ColumnLength + edx]
    shl ecx, 2
    shl edx, 6
    add edx, ecx
    mov ecx, [CardInfo + edx]

    mov edx, [SolvingDecksCount]
    shl edx, 2
    mov [SolvingInformation + edx], ecx

    inc [SolvingDecksCount]
    add [Points], 100

    .finish:
    ret
    endp


proc DrawMap, hDC

    invoke CreateSolidBrush, GAME_BCK_COLOR
    push eax
    invoke FillRect, [hDC], RectClient, eax

    cmp [IsGame], 0
    je .finish

    stdcall DrawSolvingDecks, [hDC]
    stdcall DrawNewDecks, [hDC]

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

    stdcall DrawCards, [hDC]

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
    pop eax
    invoke DeleteObject, eax

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
proc DrawCards, hDC

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
    cmp ecx, 11
    jne .startloop1

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
