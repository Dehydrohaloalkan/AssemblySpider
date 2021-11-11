
section '.cardEn' code readable executable

proc RandomInit

     mov [RandPr], 13

     ret
     endp
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


proc SetInitArrayDBG

    xor edx, edx
    mov eax, 1
    .startloop1:

        mov [edx + InitArray], eax
        inc eax
        cmp eax, 14
        jne .endloop1
        mov eax, 1

    .endloop1:
    add edx, 4
    cmp edx, 104*4
    jne .startloop1

    ret
    endp
proc SetInitArray uses esi edi

    xor edx, edx
    mov eax, 1
    .startloop1:

        mov [edx + InitArray], eax
        inc eax
        cmp eax, 14
        jne .endloop1
        mov eax, 1

    .endloop1:
    add edx, 4
    cmp edx, 104*4
    jne .startloop1

    stdcall RandomInit

    mov ecx, 50
    .startloop2:
    push ecx

        stdcall RandomGet, 0, 103
        mov edi, eax
        shl edi, 2
        stdcall RandomGet, 0, 103
        mov esi, eax
        shl esi, 2

        mov eax, [InitArray + esi]
        mov edx, [InitArray + edi]
        mov [InitArray + edi], eax
        mov [InitArray + esi], edx

    pop ecx
    loop .startloop2


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


proc SetCardsInformation uses ebx esi edi

    locals
        VerticalInterval    dd  ?
        Indent              dd  40
    endl

    mov esi, [InitPt]

    mov eax, [RectClient.right]
    xor edx, edx
    mov ebx, 11
    div ebx
    mov edx, [CardWigth]
    shr edx, 1

    mov [CenterColumnInterval], eax
    sub eax, edx

    xor edx, edx
    .startloop1:
    push edx

        shl edx, 2
        mov ecx, [ColumnLength + edx]
        mov ebx, [ColumnInterval + edx]
        mov [VerticalInterval], ebx
        mov ebx, [Indent]
        shl edx, 6

        test ecx, ecx
        jz .endloop2
        .startloop2:

            mov [CardsPositionX + edx], eax
            mov [CardsPositionY + edx], ebx

            cmp [InitFlag], 1
            je .skip

                mov edi, [InitArray + esi]
                add esi, 4

                cmp ecx, 1
                je .lasttask

                    add edi, 10h

                .lasttask:
                    mov [CardInfo + edx], edi
            .skip:

            add ebx, [VerticalInterval]
            add edx, 4

        loop .startloop2
        .endloop2:
        add eax, [CenterColumnInterval]

    pop edx
    inc edx
    cmp edx, 10
    jnz .startloop1

    mov [InitPt], esi
    mov [InitFlag], 1

    ret
    endp
proc SetCardMetrics

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
proc AddNewCards uses ebx esi edi

    mov esi, [InitPt]
    mov ecx, 10
    .startloop1:

        mov edx, ecx
        dec edx
        shl edx, 2
        mov eax, [ColumnLength + edx]
        mov edi, [ColumnInterval + edx]
        inc [ColumnLength + edx]
        shl edx, 6
        shl eax, 2
        add edx, eax

        mov ebx, [CardsPositionX + edx - 4]
        mov [CardsPositionX + edx], ebx

        mov ebx, [CardsPositionY + edx - 4]
        add ebx, edi
        mov [CardsPositionY + edx], ebx

        mov ebx, [InitArray + esi]
        mov [CardInfo + edx], ebx
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

    locals
        ColumnInt   dd  ?
    endl

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
    mov eax, [ColumnInterval + edx]
    mov [ColumnInt], eax
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
    push ecx

        invoke PtInRect, TempRect, [XPos], [YPos]
        cmp eax, 0
        jne .getinfo
        mov eax, [TempRect.top]
        sub eax, [ColumnInt]
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
        shr edx, 1
        sub eax, edx
        mov [TempRect.right], eax

        mov ecx, eax
        mov eax, [NewDecksCount]
        dec eax
        cmp eax, -1
        je .noNew
        cmp eax, 0
        je .onecard
            mov edx, 40
            mul edx
            add eax, [CardWigth]
            jmp .loading
        .onecard:
            mov eax, [CardWigth]
        .loading:
        sub ecx, eax
        mov [TempRect.left], ecx

        mov eax, [RectClient.bottom]
        sub eax, 40
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
proc CheckMoving uses ebx, Index, Column

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
    shr eax, 4
    cmp eax, 1
    je .canntmove

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
            shr eax, 4
            cmp eax, 0
            je .endloop1
            mov eax, [CardInfo + edx]
            sub eax, 10h
            mov [CardInfo + edx], eax

    .endloop1:
    pop ecx
    loop .startloop1

    ret
    endp
proc CheckSolveDeck uses ebx, Index

    shl edx, 6
    dec eax
    shl eax, 2
    add edx, eax

    mov ebx, [CardInfo + edx]
    shr ebx, 4
    cmp ebx, 1
    je .finish
    mov ebx, [CardInfo + edx]
    and ebx, 0Fh
    cmp ebx, 1
    jne .finish
    sub edx, 4

    mov ecx, 12
    .startloop1:

        mov eax, [CardInfo + edx]
        shr eax, 4
        cmp eax, 1
        je .finish
        mov eax, [CardInfo + edx]
        and eax, 0Fh
        inc ebx
        cmp eax, ebx
        jne .finish

        sub edx, 4

    loop .startloop1
    mov ecx, [Index]
    mov edx, 10
    sub edx, ecx
    shl edx, 2
    sub [ColumnLength + edx], 13
    inc [SolvingDecksCount]

    .finish:
    ret
    endp


proc DrawMap, hDC

    invoke CreateSolidBrush, 006AD8FFh
    push eax
    invoke FillRect, [hDC], RectClient, eax

    stdcall DrawSolvingDecks, [hDC]
    stdcall DrawNewDecks, [hDC]
    stdcall DrawCards, [hDC]

    mov eax, [SolvingDecksCount]
    cmp eax, 8
    jne .finish

        invoke SetTextAlign, [hDC], TA_CENTER + TA_BASELINE
        invoke SetBkMode, [hDC], TRANSPARENT
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
    shr eax, 1
    mov [XPos], eax

    mov eax, [RectClient.bottom]
    sub eax, [CardHeight]
    sub eax, 40
    mov [YPos], eax

    .startloop1:
    push ecx
        stdcall GetTextureCardIndex, 13
        stdcall DrawCard, [hDC], [XPos], [YPos], eax, [hCards]
        mov eax, [XPos]
        add eax, 40
        mov [XPos], eax
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
    shr edx, 1
    sub eax, edx
    sub eax, [CardWigth]
    mov [XPos], eax

    mov eax, [RectClient.bottom]
    sub eax, [CardHeight]
    sub eax, 40
    mov [YPos], eax

    .startloop1:
    push ecx
        stdcall GetTextureCardIndex, 0
        stdcall DrawCard, [hDC], [XPos], [YPos], eax, [hCards]
        mov eax, [XPos]
        sub eax, 40
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

        test ecx, ecx
        jz .endloop2
        .startloop2:
        push ecx edx edx
            stdcall GetTextureCardIndex, [CardInfo + edx]
            pop edx
            stdcall DrawCard, [hDC], [CardsPositionX + edx], [CardsPositionY + edx], eax, [hCards]

        pop edx ecx
        add edx, 4
        loop .startloop2
        .endloop2:

    pop ecx
    inc ecx
    cmp ecx, 11
    jne .startloop1

    ret
    endp
proc DrawCard, hDC, left, top, index, hcard

    locals
        hCardDC dd  ?
    endl

    invoke CreateCompatibleDC, [hDC]
    mov [hCardDC], eax
    invoke SelectObject, [hCardDC], [hcard]
    mov [hcard], eax

    mov eax, [index]
    mov edx, CardResolutionX
    mul edx

    invoke TransparentBlt, [hDC], [left], [top], [CardWigth], [CardHeight], \
                         [hCardDC], eax, 0, CardResolutionX, CardResolutionY, 00FF8080h


    invoke SelectObject, [hCardDC], [hcard]
    invoke DeleteDC, [hCardDC]

    ret
    endp
proc GetTextureCardIndex, Info

    mov eax, [Info]
    shr eax, 4
    cmp eax, 1
    je .closecard

    mov eax, [Info]
    and eax, 0Fh
    jmp .finish

    .closecard:
        xor eax, eax

    .finish:
    ret
    endp
