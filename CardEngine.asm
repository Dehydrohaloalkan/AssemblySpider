
section '.cardEn' code readable executable

proc Game.PreInitCards

    xor edx, edx
    .startloop1:
        mov [Cards + edx], 0
    add edx, 4
    cmp edx, 104 * CRD_Size
    jne .startloop1

    ret
    endp
proc Game.PreInitColumns

    xor edx, edx
    .startloop1:
        mov [Cards + edx], 0
    add edx, 4
    cmp edx, 12 * CRD_Size
    jne .startloop1

    ret
    endp
proc Game.InitCardInfo uses esi edi, SuitCount

    mov ecx, 104
    xor edx, edx
    xor esi, esi
    xor edi, edi
    .startloop1:

        MSetCardNominal [Cards + edx], edi
        MSetCardsuit    [Cards + edx], esi

        add edx, CRD_Size
        inc edi
        cmp edi, 13
        jne .endloop1
        xor edi, edi
        inc esi
        cmp esi, [SuitCount]
        jne .endloop1
        xor esi, esi

    .endloop1:
    loop .startloop1

    ret
    endp
proc Game.SetStartLayOut

    locals
        Card    dd  ?
        Column  dd  ?
    endl

    mov ecx, 10
    mov [Card], Cards
    mov [Column], Columns
    .startloop1:
        push ecx

        cmp ecx, 6
        jg .bigcolumn
            mov ecx, 5
            jmp .startloop2
        .bigcolumn:
            mov ecx, 6

        .startloop2:
            push ecx

            stdcall Card.Close, [Card]
            stdcall Column.Append, [Column], [Card]
            add [Card], CRD_Size

            pop ecx
        loop .startloop2

        mov eax, [Card]
        sub eax, CRD_Size
        stdcall Card.Open, eax
        add [Column], CRD_Size

        pop ecx
    loop .startloop1

    ret
    endp
proc Game.Start

    stdcall Game.PreInitCards
    stdcall Game.PreInitColumns
    stdcall Game.InitCardInfo, 1
    stdcall Metrics.Calculate
    stdcall Metrics.SetColumnPositions
    stdcall Game.SetStartLayOut

    mov ecx, 10
    mov edx, Columns
    .startloop1:
        push ecx edx
        stdcall Column.SetCardsAims, edx
        pop edx ecx
        add edx, CRD_Size
    loop .startloop1

    mov ecx, 54
    mov edx, Cards
    mov eax, 0
    .startloop2:
        push ecx edx eax
        stdcall Card.InitAnimation, edx, eax
        pop eax edx ecx
        add edx, CRD_Size
        add eax, 5
    loop .startloop2

    ;stdcall Metrics.SetAllCardsPositions

    ret
    endp

proc Game.OnSize

    stdcall Metrics.Calculate
    stdcall Metrics.SetColumnPositions
    stdcall Metrics.SetAllCardsPositions

    ret
    endp
proc Game.OnPaint

    invoke GetTickCount
    sub eax, [Clock]
    cmp eax, 10
    jb .skipanimation
        stdcall Animation.Run
        add [Clock], eax
    .skipanimation:
    stdcall Map.Draw, [hdcDoubleBuffer]

    ret
    endp
proc Game.OnMouseDown

    mov eax, [HighWord]
    mov [saveY], eax
    mov eax, [LowWord]
    mov [saveX], eax

    ;stdcall Game.Start
    ;mov DWORD [Cards + CRD_XAim], 500
    ;mov DWORD [Cards + CRD_YAim], 500
    ;stdcall Card.InitAnimation, Cards, 0
    bts [Flags], IS_MOUSE_DOWN

    ret
    endp
proc Game.OnMouseMove

    bt [Flags], IS_MOUSE_DOWN
    jnc .finish

    mov eax, [HighWord]
    sub eax, [saveY]
    add [Cards + CRD_YCord], eax
    mov eax, [LowWord]
    sub eax, [saveX]
    add [Cards + CRD_XCord], eax

    mov eax, [LowWord]
    mov [saveX], eax
    mov eax, [HighWord]
    mov [saveY], eax

    .finish:
    ret
    endp
proc Game.OnMouseUp

    btr [Flags], IS_MOUSE_DOWN
    mov DWORD [Cards + CRD_XAim], 500
    mov DWORD [Cards + CRD_YAim], 500
    stdcall Card.InitAnimation, Cards, 0

    ret
    endp


proc Metrics.SetColumnPositions uses ebx

    mov eax, [CenterColumnInterval]
    mov edx, [CardWigth]
    shr edx, 1
    sub eax, edx
    mov ebx, [Indent]
    xor edx, edx
    mov ecx, 10
    .startloop1:
        mov [Columns + edx + CRD_XCord], eax
        mov [Columns + edx + CRD_XAim], eax
        mov [Columns + edx + CRD_YCord], ebx
        mov [Columns + edx + CRD_YAim], ebx
        add eax, [CenterColumnInterval]
        add edx, CRD_Size
    loop .startloop1

    ret
    endp
proc Metrics.SetAllCardsPositions

    stdcall Animation.Stop

    mov ecx, 10
    mov edx, Columns
    .startloop1:
        push ecx edx
        stdcall Column.NoAnimMove, edx
        pop edx ecx
        add edx, CRD_Size
    loop .startloop1

    ret
    endp
proc Metrics.Calculate
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


proc Column.Append, Column, Card

    mov edx, [Column]
    stdcall Column.FindEnd, edx
    mov edx, eax
    mov eax, [Card]
    mov [edx + CRD_NextRef], eax
    mov ecx, edx
    mov edx, eax
    mov [edx + CRD_PredRef], ecx

    ret
    endp
proc Column.Remove, Column, Card

    mov edx, [Column]
    .startloop1:

        mov eax, edx
        mov ecx, [edx + CRD_NextRef]
        mov edx, ecx

    cmp edx, [Card]
    jnz .startloop1

    mov edx, eax
    mov [edx + CRD_NextRef], 0

    ret
    endp
proc Column.FindEnd, Column

    mov edx, [Column]
    .startloop1:

        mov eax, edx
        mov ecx, [edx + CRD_NextRef]
        mov edx, ecx

    test edx, edx
    jnz .startloop1

    ret
    endp
proc Column.Lenght, Column

    xor eax, eax
    mov edx, [Column]
    .startloop1:

        inc eax
        mov ecx, [edx + CRD_NextRef]
        mov edx, ecx

    test edx, edx
    jnz .startloop1
    dec eax

    ret
    endp
proc Column.SetCardsAims uses edi, Column

    stdcall Column.SetCardsIntervals, [Column]

    mov edx, [Column]
    .startloop1:
        mov edi, edx
        mov eax, [edx + CRD_NextRef]
        mov edx, eax

        test edx, edx
        jz .finish

        mov eax, [edi + CRD_XAim]
        mov [edx + CRD_XAim], eax

        mov eax, [edi + CRD_YAim]
        add eax, [edi + CRD_Indent]
        mov [edx + CRD_YAim], eax

    jmp .startloop1
    .finish:

    ret
    endp
proc Column.NoAnimMove, Column

    stdcall Column.SetCardsAims, [Column]

    mov edx, [Column]
    .startloop1:
        mov eax, [edx + CRD_NextRef]
        test eax, eax
        jz .finloop1
        mov edx, eax
        mov eax, [edx + CRD_XAim]
        mov [edx + CRD_XCord], eax
        mov eax, [edx + CRD_YAim]
        mov [edx + CRD_YCord], eax
    jmp .startloop1
    .finloop1:


    ret
    endp
proc Column.SetCardsIntervals, Column

    mov edx, [Column]
    .startloop1:
        mov eax, [edx + CRD_NextRef]
        test eax, eax
        jz .finloop1
        mov edx, eax
        mov eax, [CardHeight]
        shr eax, 3
        mov [edx + CRD_Indent], eax
    jmp .startloop1
    .finloop1:

    ret
    endp
proc Column.Draw, Column, hdc

    mov edx, [Column]
    mov eax, [edx + CRD_NextRef]
    test eax, eax
    jz .empty
    .startloop1:
        mov edx, eax
        push edx
        stdcall Card.Draw, edx, [hdc]
        pop edx
        mov eax, [edx + CRD_NextRef]
        test eax, eax
        jnz .startloop1
        jmp .finish
    .empty:
        stdcall Column.DrawEmpty, edx, [hdc]
    .finish:
    ret
    endp
proc Column.DrawEmpty, Column, hdc



    ret
    endp


proc Animation.Append, Card

    mov edx, AnimColumn
    .startloop1:
        mov eax, edx
        mov ecx, [edx + CRD_NextAnimRef]
        mov edx, ecx
    test edx, edx
    jnz .startloop1

    mov edx, eax
    mov eax, [Card]
    mov [edx + CRD_NextAnimRef], eax

    ret
    endp
proc Animation.Remove, Card

    mov edx, AnimColumn
    .startloop1:
        mov eax, edx
        mov ecx, [edx + CRD_NextAnimRef]
        mov edx, ecx
    cmp edx, [Card]
    jne .startloop1

    mov ecx, [edx + CRD_NextAnimRef]
    mov DWORD [edx + CRD_NextAnimRef], 0
    mov edx, eax
    mov [edx + CRD_NextAnimRef], ecx

    ret
    endp
proc Animation.Run

    mov edx, AnimColumn
    .startloop1:

        mov eax, [edx + CRD_NextAnimRef]
        test eax, eax
        jz .finish
        push eax
        stdcall Card.Animation, eax
        pop eax
        mov edx, eax

    jmp .startloop1
    .finish:

    ret
    endp
proc Animation.Stop

    mov edx, AnimColumn
    mov eax, [edx + CRD_NextAnimRef]
    .startloop1:
        test eax, eax
        jz .finloop1
        mov edx, eax
        mov eax, [edx + CRD_NextAnimRef]
        push edx eax
        stdcall Card.EndAnimation, edx
        pop eax edx
    jmp .startloop1
    .finloop1:

    ret
    endp


proc Card.SetTextureCords uses edi, Card
    mov edi, [Card]
    bt DWORD [edi + CRD_Info], INF_IsClose
    jc .closecard
        mov edx, CARD_RESOLUTION_X
        MGetCardNominal [edi + CRD_Info]
        mul edx
        mov [edi + CRD_XTexture], eax

        mov edx, CARD_RESOLUTION_Y
        MGetCardSuit [edi + CRD_Info]
        mul edx
        mov [edi + CRD_YTexture], eax
        jmp .finish
    .closecard:
        mov eax, CARD_RESOLUTION_X
        mov edx, [BackCardIndex]
        mul edx
        mov [edi + CRD_XTexture], eax

        mov eax, CARD_RESOLUTION_Y
        shl eax, 2
        mov [edi + CRD_YTexture], eax
    .finish:
    ret
    endp
proc Card.Close, Card

    mov edx, [Card]
    bts DWORD [edx + CRD_Info], INF_IsClose
    stdcall Card.SetTextureCords, edx

    ret
    endp
proc Card.Open, Card

    mov edx, [Card]
    btr DWORD [edx + CRD_Info], INF_IsClose
    stdcall Card.SetTextureCords, edx

    ret
    endp
proc Card.Draw, Card, hdc

    locals
        hCardDC dd  ?
    endl

    invoke CreateCompatibleDC, [hdc]
    mov [hCardDC], eax
    invoke SelectObject, [hCardDC], [hTextures]
    mov [hTextures], eax

    mov edx, [Card]
    invoke TransparentBlt, [hdc], [edx + CRD_XCord], [edx + CRD_YCord], \
    [CardWigth], [CardHeight], [hCardDC], [edx + CRD_XTexture], [edx + CRD_YTexture], \
    CARD_RESOLUTION_X, CARD_RESOLUTION_Y, 00FF8080h

    invoke SelectObject, [hCardDC], [hTextures]
    mov [hTextures], eax
    invoke DeleteDC, [hCardDC]

    ret
    endp
proc Card.InitAnimation, Card, WaitTime

    mov edx, [Card]

    mov eax, [WaitTime]
    test eax, eax
    jz .anim
        bts DWORD [edx + CRD_Info], INF_IsWait
        mov [edx + CRD_AnimWait], eax
        jmp .animcalculate
    .anim:
        bts DWORD [edx + CRD_Info], INF_IsAnim

    .animcalculate:
    mov eax, [edx + CRD_XAim]
    sub eax, [edx + CRD_XCord]
    cdq
    mov ecx, ANIMATION_TIME
    idiv ecx
    push eax

    mov edx, [Card]
    mov eax, [edx + CRD_YAim]
    sub eax, [edx + CRD_YCord]
    cdq
    mov ecx, ANIMATION_TIME
    idiv ecx
    push eax

    mov edx, [Card]
    pop DWORD [edx + CRD_YAnim]
    pop DWORD [edx + CRD_XAnim]

    mov DWORD [edx + CRD_AnimCount], ANIMATION_TIME

    stdcall Animation.Append, edx

    ret
    endp
proc Card.Animation, Card

    mov edx, [Card]
    bt DWORD [edx + CRD_Info], INF_IsWait
    jc .wait
    bt DWORD [edx + CRD_Info], INF_IsAnim
    jc .anim

    .wait:
        dec DWORD [edx + CRD_AnimWait]
        cmp DWORD [edx + CRD_AnimWait], -1
        jne .finish
            bts DWORD [edx + CRD_Info], INF_IsAnim
            btr DWORD [edx + CRD_Info], INF_IsWait

    .anim:
        mov eax, [edx + CRD_XAnim]
        add [edx + CRD_XCord], eax
        mov eax, [edx + CRD_YAnim]
        add [edx + CRD_YCord], eax
        dec DWORD [edx + CRD_AnimCount]
        cmp DWORD [edx + CRD_AnimCount], -1
        jne .finish
            stdcall Card.EndAnimation, edx

    .finish:
    ret
    endp
proc Card.EndAnimation, Card

    mov edx, [Card]
    btr DWORD [edx + CRD_Info], INF_IsAnim
    mov eax, [edx + CRD_XAim]
    mov [edx + CRD_XCord], eax
    mov eax, [edx + CRD_YAim]
    mov [edx + CRD_YCord], eax

    mov DWORD [edx + CRD_XAim], 0
    mov DWORD [edx + CRD_YAim], 0
    stdcall Animation.Remove, edx

    ret
    endp


proc Map.Draw, hdc

    invoke CreateCompatibleDC, [hdc]
    mov [hdcBackBuffer], eax
    invoke SelectObject, [hdcBackBuffer], [hBackBuffer]

    invoke BitBlt, [hdc], 0, 0, [RectClient.right], [RectClient.bottom], [hdcBackBuffer], 0, 0, SRCCOPY
    ;stdcall Card.Draw, Cards, [hdc]

    invoke DeleteDC, [hdcBackBuffer]

    ret
    endp
proc Map.CreateBackBuffer, hdc

    invoke CreateCompatibleDC, [hdc]
    mov [hdcBackBuffer], eax
    invoke SelectObject, [hdcBackBuffer], [hBackBuffer]

    invoke CreateSolidBrush, GAME_BCK_COLOR
    push eax
    invoke FillRect, [hdcBackBuffer], RectClient, eax

    stdcall Map.DrawStaticCards, [hdcBackBuffer]


    invoke DeleteDC, [hdcBackBuffer]
    pop eax
    invoke DeleteObject, eax

    ret
    endp
proc Map.DrawStaticCards, hdc

    mov edx, Columns
    mov ecx, 10
    .startloop1:
        push ecx edx
        stdcall Column.Draw, edx, [hdc]
        pop edx ecx
        add edx, CRD_Size
    loop .startloop1

    ret
    endp
proc Map.DrawMovingCards, hdc



    ret
    endp
proc Map.DrawSolvingDecks, hdc



    ret
    endp
proc Map.DrawNewDecks, hdc



    ret
    endp
proc Map.DrawPointCounter, hdc

    invoke SetTextAlign, [hdc], TA_CENTER + TA_BOTTOM
    invoke SetBkMode, [hdc], TRANSPARENT
    invoke CreateFontIndirect, font
    push eax
    invoke SelectObject, [hdc], eax

    stdcall IntToStr, [Points], _PointsStr + 8

    push [_PointsStrLen]
    push _PointsStr
    mov eax, [RectClient.bottom]
    sub eax, [DownInterval]
    push eax
    mov eax, [RectClient.right]
    shr eax, 1
    invoke TextOut, [hdc], eax

    pop eax
    invoke DeleteObject, eax

    ret
    endp
