
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

    locals
        StartX  dd  ?
        StartY  dd  ?
    endl

    stdcall Game.PreInitCards
    stdcall Game.PreInitColumns
    stdcall Game.InitCardInfo, 1
    stdcall Metrics.Calculate
    stdcall Metrics.SetColumnPositions
    stdcall Game.SetStartLayOut
    stdcall NewColumn.InfoInit
    stdcall NewColumn.SetPositions

    mov ecx, 10
    mov edx, Columns
    .startloop1:
        push ecx edx
        stdcall Column.SetCardsAims, edx
        pop edx ecx
        add edx, CRD_Size
    loop .startloop1

    stdcall Column.FindEnd, NewColumn
    mov edx, eax
    mov eax, [edx + CRD_XCord]
    mov [StartX], eax
    mov eax, [edx + CRD_YCord]
    mov [StartY], eax

    mov ecx, 54
    mov edx, Cards
    mov eax, 0
    .startloop2:
        push eax
        mov eax, [StartX]
        mov [edx + CRD_XCord], eax
        mov eax, [StartY]
        mov [edx + CRD_YCord], eax
        pop eax
        push ecx eax edx
        stdcall Card.InitAnimation, edx, eax, 12
        pop edx eax ecx
        add edx, CRD_Size
        add eax, 2
    loop .startloop2

    ret
    endp
proc Game.InitEnd

    locals
        EndX    dd  ?
        EndY    dd  ?
        DelX    dd  ?
        DelY    dd  ?
        Wait    dd  0
    endl

    mov [SolveCount], 0
    bts [Flags], IS_GameEnd

    mov eax, [RectClient.right]
    mov ecx, 13
    xor edx, edx
    div ecx
    mov [DelX], eax

    mov eax, [RectClient.bottom]
    xor edx, edx
    div ecx
    mov [DelY], eax

    mov [EndX], 0
    mov [EndY], 0

    stdcall Column.FindEnd, SolveColumn
    mov edx, eax

    mov ecx, 4
    .startloop1:
        push ecx
        mov ecx, 13
        .startloop2:
            push ecx
                mov eax, [EndX]
                mov [edx + CRD_XAim], eax
                mov eax, [EndY]
                mov [edx + CRD_YAim], eax
                push edx
                    stdcall Card.InitAnimation, edx, [Wait], ANIMATION_TIME * 2
                pop edx
                mov DWORD [edx + CRD_AnimCount], ANIMATION_TIME * 4
                mov DWORD [edx + CRD_XAim], -1000
                mov DWORD [edx + CRD_YAim], -1000

                mov eax, [edx + CRD_PredRef]
                mov edx, eax
                add [Wait], 1

                mov eax, [DelX]
                add [EndX], eax
                mov eax, [DelY]
                add [EndX], eax
            pop ecx
        loop .startloop2
        mov ecx, 13
        .startloop3:
            push ecx
                mov eax, [EndX]
                mov [edx + CRD_XAim], eax
                mov eax, [EndY]
                mov [edx + CRD_YAim], eax
                push edx
                    stdcall Card.InitAnimation, edx, [Wait], ANIMATION_TIME * 2
                pop edx
                mov DWORD [edx + CRD_AnimCount], ANIMATION_TIME * 4
                mov DWORD [edx + CRD_XAim], -1000
                mov DWORD [edx + CRD_YAim], -1000

                mov eax, [edx + CRD_PredRef]
                mov edx, eax
                add [Wait], 1

                mov eax, [DelX]
                sub [EndX], eax
                mov eax, [DelY]
                sub [EndX], eax
            pop ecx
        loop .startloop3
        pop ecx
    dec ecx
    jnz .startloop1

    ret
    endp
proc Game.FindColumn, XCord, YCord

    mov eax, [XCord]
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

    mov edx, CRD_Size
    mul edx
    add eax, Columns
    jmp .finish
    .nocolumn:
        xor eax, eax
    .finish:
    ret
    endp
proc Game.FindCard, XCord, YCord

    stdcall Game.FindColumn, [XCord], [YCord]
    test eax, eax
    jz .nocard

    stdcall Column.FindCard, eax, [XCord], [YCord]
    jmp .finish
    .nocard:
        xor eax, eax
    .finish:
    ret
    endp
proc Game.Solve

    mov ecx, 10
    mov edx, Columns
    .startloop1:
        push ecx edx
        stdcall Column.Solve, edx
        pop edx ecx
        add edx, CRD_Size
    loop .startloop1

    ret
    endp
proc Game.CardsReplace

    locals
        Column  dd  ?
    endl

    mov ecx, 10
    mov [Column], Columns
    .startloop1:
        push ecx
        stdcall Column.SetCardsAims, [Column]
        stdcall Column.InitAnimation, [Column], 0, ANIMATION_TIME
        add [Column], CRD_Size
        pop ecx
    loop .startloop1

    ret
    endp

proc Game.OnSize, hwnd

    stdcall Animation.Stop
    stdcall Metrics.Calculate
    stdcall Metrics.SetColumnPositions
    stdcall Metrics.SetAllCardsPositions
    stdcall NewColumn.SetPositions
    stdcall SolveColumn.SetPositions

    MCreateBackBuffer

    ret
    endp
proc Game.OnPaint, hwnd

    bt [Flags], IS_Animation
    jnc .afteranimation
    invoke GetTickCount
    sub eax, [Clock]
    cmp eax, 10
    jb .skipanimation
        btr [Flags], IS_Animation
        bts [Flags], IS_NeedCheck
        stdcall Animation.Run
        add [Clock], eax
        jmp .skipanimation
    .afteranimation:
        btr [Flags], IS_NeedCheck
        jnc .check
            stdcall Game.Solve
        jmp .skipanimation
        .check:
        btr [Flags], IS_NeedAnim
        jnc .end
            stdcall Game.CardsReplace
            btr [Flags], IS_CanMove
        jmp .skipanimation
        .end:
        cmp [SolveCount], 8
        jne .skipanimation
            stdcall Game.InitEnd
    .skipanimation:
        btr [Flags], IS_NeedBB
        jnc .noneed
            MCreateBackBuffer
        .noneed:

    stdcall Map.Draw, [hdcDoubleBuffer]

    ret
    endp
proc Game.OnMouseDown, hwnd

    bts [Flags], IS_Mouse_Down
    mov eax, [HighWord]
    mov [saveY], eax
    mov eax, [LowWord]
    mov [saveX], eax

    bt [Flags], IS_CanMove
    jc .skip

    stdcall Game.FindCard, [saveX], [saveY]
    test eax, eax
    jz .check
        stdcall Column.CheckMoving, eax
        test eax, eax
        jz .check
        stdcall Column.Replace, MovingColumn, eax
        jmp .skip
    .check:
    stdcall NewColumn.CheckCollision, [saveX], [saveY]
    test eax, eax
    jz .skip
        stdcall NewColumn.CheckGeting
        test eax, eax
        jz .skip
        stdcall NewColumn.GetNewCards
    .skip:
    MCreateBackBuffer

    ret
    endp
proc Game.OnMouseMove

    bt [Flags], IS_Mouse_Down
    jnc .finish

        mov eax, [HighWord]
        sub eax, [saveY]
        push eax
        mov eax, [LowWord]
        sub eax, [saveX]
        push eax

        stdcall Column.Move

        mov eax, [LowWord]
        mov [saveX], eax
        mov eax, [HighWord]
        mov [saveY], eax

    .finish:
    ret
    endp
proc Game.OnMouseUp

    locals
        Column      dd  ?
        OldColumn   dd  ?
        Card        dd  ?
    endl

    btr [Flags], IS_Mouse_Down

    mov edx, [MovingColumn + CRD_NextRef]
    mov [Card], edx
    test edx, edx
    jz .finish

    mov eax, [edx + CRD_OldColumn]
    mov [OldColumn], eax
    stdcall Game.FindColumn, [LowWord], [HighWord]
    test eax, eax
    jz .old

    mov [Column], eax

    mov edx, [MovingColumn + CRD_NextRef]
    stdcall Column.CheckPlacing, eax, edx

    cmp eax, [OldColumn]
    je .old
        stdcall Column.Replace, [Column], [Card]
        stdcall Column.SetCardsAims, [Column]
        stdcall Column.InitAnimation, [Column], 0, ANIMATION_TIME
        stdcall Column.SetCardsAims, [OldColumn]
        stdcall Column.InitAnimation, [OldColumn], 0, ANIMATION_TIME
        stdcall Column.FindEnd, [OldColumn]
        cmp eax, [OldColumn]
        je .set
            stdcall Card.Open, eax
        .set:
        dec [Points]
        jmp .finish
    .old:
        stdcall Column.Replace, [OldColumn], [Card]
        stdcall Column.SetCardsAims, [OldColumn]
        stdcall Column.InitAnimation, [OldColumn], 0, ANIMATION_TIME

    .finish:
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
    shr eax, 2
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
    mov edx, [Card]

    mov eax, [edx + CRD_Column]
    mov [edx + CRD_OldColumn], eax
    mov eax, [Column]
    mov [edx + CRD_Column], eax

    .startloop1:
        mov eax, [edx + CRD_NextRef]
        test eax, eax
        jz .finloop1
        mov edx, eax

        mov eax, [edx + CRD_Column]
        mov [edx + CRD_OldColumn], eax
        mov eax, [Column]
        mov [edx + CRD_Column], eax

    jmp .startloop1
    .finloop1:

    ret
    endp
proc Column.Remove, Column, Card

    mov edx, [Column]
    .startloop1:
        mov eax, [edx + CRD_NextRef]
        cmp eax, [Card]
        je .finloop1
        mov edx, eax
    jmp .startloop1
    .finloop1:

    mov DWORD [edx + CRD_NextRef], 0
    mov edx, eax
    mov DWORD [edx + CRD_PredRef], 0

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
proc Column.Length, Column

    mov edx, [Column]
    xor eax, eax
    .startloop1:
        mov ecx, [edx + CRD_NextRef]
        test ecx, ecx
        jz .finloop1
        mov edx, ecx
        inc eax
    jmp .startloop1
    .finloop1:

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

    locals
        OpenInterval    dd  ?
        CloseInterval   dd  ?
        Workspace       dd  ?
        LogicPoints     dd  ?
    endl

    xor ecx, ecx
    mov edx, [Column]
    .startloop1:
        mov eax, [edx + CRD_NextRef]
        test eax, eax
        jz .finloop1
        mov edx, eax
        add ecx, 2
        bt DWORD [edx + CRD_Info], INF_IsClose
        sbb ecx, 0
    jmp .startloop1
    .finloop1:
    add ecx, 10
    mov [LogicPoints], ecx

    mov eax, [RectClient.bottom]
    shr eax, 2
    mov edx, 3
    mul edx
    mov [Workspace], eax

    mov eax, [CardHeight]
    shr eax, 2
    mov [OpenInterval], eax
    shr eax, 1
    mov [CloseInterval], eax

    mov edx, [LogicPoints]
    mul edx

    cmp eax, [Workspace]
    jl .endcalculate

        mov eax, [Workspace]
        xor edx, edx
        div ecx
        mov [CloseInterval], eax
        shl eax, 1
        mov [OpenInterval], eax

    .endcalculate:
    mov edx, [Column]
    .startloop2:
        mov eax, [edx + CRD_NextRef]
        test eax, eax
        jz .finloop2
        mov edx, eax
        bt DWORD [edx + CRD_Info], INF_IsClose
        jc .closecard
            mov eax, [OpenInterval]
            mov [edx + CRD_Indent], eax
            jmp .startloop2
        .closecard:
            mov eax, [CloseInterval]
            mov [edx + CRD_Indent], eax
            jmp .startloop2
    .finloop2:

    ret
    endp
proc Column.Draw, Column, hdc

    cmp [Column], MovingColumn
    je .looppreparation
    cmp [Column], NewColumn
    je .looppreparation
    cmp [Column], SolveColumn
    je .looppreparation
        stdcall Column.DrawEmpty, [Column], [hdc]
    .looppreparation:
        mov edx, [Column]
        mov eax, [edx + CRD_NextRef]
        test eax, eax
        jz .finish
    .startloop1:
        mov edx, eax
        push edx
        bt DWORD [edx + CRD_Info], INF_IsAnim
        jc .skip
            stdcall Card.Draw, edx, [hdc]
        .skip:
        pop edx
        mov eax, [edx + CRD_NextRef]
        test eax, eax
        jnz .startloop1
    .finish:

    ret
    endp
proc Column.DrawEmpty, Column, hdc

    locals
        hbruh   dd  ?
        hpen    dd  ?
    endl

    mov eax, GAME_BCK_COLOR
    and eax, 00B0B0B0h
    invoke CreateSolidBrush, eax
    invoke SelectObject, [hdc], eax
    mov [hbruh], eax

    invoke CreatePen, PS_SOLID, 3, 00000000h
    invoke SelectObject, [hdc], eax
    mov [hpen], eax

    push 20 20
    mov edx, [Column]

    mov eax, [edx + CRD_YCord]
    add eax, [CardHeight]
    sub eax, 4
    push eax

    mov eax, [edx + CRD_XCord]
    add eax, [CardWigth]
    sub eax, 4
    push eax

    mov eax, [edx + CRD_YCord]
    add eax, 2
    push eax
    mov eax, [edx + CRD_XCord]
    add eax, 2
    push eax
    invoke RoundRect, [hdc]

    invoke SelectObject, [hdc], [hpen]
    invoke DeleteObject, eax
    invoke SelectObject, [hdc], [hbruh]
    invoke DeleteObject, eax

    ret
    endp
proc Column.FindCard, Column, XCord, YCord

    stdcall Column.FindEnd, [Column]
    mov edx, eax
    cmp edx, [Column]
    je .finloop1
    .startloop1:
        cmp eax, [Column]
        je .finloop1
        mov edx, eax
        push edx
        stdcall Card.CheckCollision, edx, [XCord], [YCord]
        pop edx
        test eax, eax
        jnz .find
        mov eax, [edx + CRD_PredRef]
    jmp .startloop1
    .finloop1:
        xor eax, eax
        jmp .finish
    .find:
        mov edx, eax
        xor eax, eax
        bt DWORD [edx + CRD_Info], INF_IsAnim
        jc .finish
        mov eax, edx
    .finish:
    ret
    endp
proc Column.Replace, NewColumn, Card

    mov edx, [Card]
    stdcall Column.Remove, [edx + CRD_Column], edx
    stdcall Column.Append, [NewColumn], [Card]

    ret
    endp
proc Column.Move, deltaX, deltaY

    mov edx, MovingColumn
    .startloop1:
        mov eax, [edx + CRD_NextRef]
        test eax, eax
        jz .finloop1
        mov edx, eax
        mov eax, [deltaX]
        add [edx + CRD_XCord], eax
        mov eax, [deltaY]
        add [edx + CRD_YCord], eax
    jmp .startloop1
    .finloop1:

    ret
    endp
proc Column.CheckMoving, Column

    mov edx, [Column]
    bt DWORD [edx + CRD_Info], INF_IsClose
    jc .no
    MGetCardNominal [edx + CRD_Info]
    mov ecx, eax
    .startloop1:
        MGetCardNominal [edx + CRD_Info]
        cmp eax, ecx
        jne .no
        dec ecx
        mov eax, [edx + CRD_NextRef]
        test eax, eax
        jz .yes
        mov edx, eax
    jmp .startloop1
    .yes:
        mov eax, [Column]
        jmp .finish
    .no:
        xor eax, eax
    .finish:
    ret
    endp
proc Column.CheckPlacing, Column, Card

    mov edx, [Column]
    cmp DWORD [edx + CRD_NextRef], 0
    je .newcolumn

    stdcall Column.FindEnd, edx
    mov edx, eax

    MGetCardNominal [edx + CRD_Info]
    mov ecx, eax
    dec ecx

    mov edx, [Card]
    MGetCardNominal [edx + CRD_Info]
    cmp ecx, eax
    jne .oldcolumn
    .newcolumn:
        mov eax, [Column]
        jmp .finish
    .oldcolumn:
        mov eax, [edx + CRD_OldColumn]
    .finish:
    ret
    endp
proc Column.InitAnimation, Column, WaitTime, AnimTime

    mov edx, [Column]
    .startloop1:
        mov eax, [edx + CRD_NextRef]
        test eax, eax
        jz .finloop1
        mov edx, eax
        push edx
        stdcall Card.InitAnimation, edx, [WaitTime], [AnimTime]
        pop edx
    jmp .startloop1
    .finloop1:

    ret
    endp
proc Column.Solve, Column

    stdcall Column.CheckSolving, [Column]
    test eax, eax
    jz .finish

        stdcall Column.FindEnd, [Column]
        push eax
        mov ecx, 13
        .startloop1:
            mov edx, eax
            mov eax, [edx + CRD_PredRef]
            push eax ecx edx
            stdcall Column.Replace, SolveColumn, edx
            pop edx ecx eax
        loop .startloop1

        inc [SolveCount]
        add [Points], 100
        bts [Flags], IS_NeedAnim
        stdcall SolveColumn.SetCardsAims

        pop edx
        mov ecx, 0
        .startloop2:
            push edx ecx
                stdcall Card.InitAnimation, edx, ecx, ANIMATION_TIME
            pop ecx edx
            mov eax, [edx + CRD_NextRef]
            test eax, eax
            jz .finloop2
            mov edx, eax
            add ecx, DEFAULT_ANIM_WAIT
        jmp .startloop2
        .finloop2:

        stdcall Column.FindEnd, [Column]
        test eax, eax
        jz .finish
            stdcall Card.Open, eax

    .finish:
    ret
    endp
proc Column.CheckSolving, Column

    locals
        Nominal dd  0
    endl

    stdcall Column.Length, [Column]
    cmp eax, 13
    jl .no

    stdcall Column.FindEnd, [Column]

    mov edx, eax
    mov ecx, 13
    .startloop1:
        MGetCardNominal [edx + CRD_Info]
        cmp eax, [Nominal]
        jne .no
        bt DWORD [edx + CRD_Info], INF_IsClose
        jc .no
        inc [Nominal]
        mov eax, [edx + CRD_PredRef]
        mov edx, eax
    loop .startloop1
        mov eax, [edx + CRD_NextRef]
        jmp .finish
    .no:
        xor eax, eax
    .finish:
    ret
    endp


proc NewColumn.InfoInit

    mov edx, Cards + 103 * CRD_Size
    mov ecx, 50
    .startloop1:
        push ecx edx
        stdcall Column.Append, NewColumn, edx
        pop edx
        push edx
        stdcall Card.Close, edx
        pop edx ecx
        sub edx, CRD_Size
    loop .startloop1

    ret
    endp
proc NewColumn.SetPositions

    locals
        XCord   dd  ?
        YCord   dd  ?
    endl

    mov eax, [RectClient.right]
    sub eax, [CenterColumnInterval]
    sub eax, [CardWigth]
    mov [XCord], eax

    mov eax, [RectClient.bottom]
    sub eax, [DownInterval]
    sub eax, [CardHeight]
    mov [YCord], eax

    mov ecx, [NewCount]
    test ecx, ecx
    jz .finish
    mov eax, [NewColumn + CRD_NextRef]
    test eax, eax
    jz .finish
    mov edx, eax
    .startloop1:
        push ecx

        mov ecx, 10
        .startloop2:
            mov eax, [XCord]
            mov [edx + CRD_XCord], eax
            mov eax, [YCord]
            mov [edx + CRD_YCord], eax
            mov eax, [edx + CRD_NextRef]
            mov edx, eax
        loop .startloop2

        mov eax, [XCord]
        sub eax, [DownInterval]
        mov [XCord], eax

        pop ecx
    loop .startloop1

    .finish:
    ret
    endp
proc NewColumn.CheckCollision, XCord, YCord

    mov eax, [RectClient.bottom]
    sub eax, [DownInterval]
        mov [TempRect.bottom], eax
    sub eax, [CardHeight]
        mov [TempRect.top], eax

    mov edx, [DownInterval]
    mov eax, [NewCount]
    dec eax
    mul edx
    add eax, [CardWigth]

    mov edx, [RectClient.right]
    sub edx, eax
        mov [TempRect.right], edx
    add eax, [CenterColumnInterval]
    sub edx, eax
        mov [TempRect.left], edx

    invoke PtInRect, TempRect, [XCord], [YCord]

    ret
    endp
proc NewColumn.CheckGeting

    bt [Flags], IS_Animation
    jc .no

    mov ecx, 10
    mov edx, Columns
    .startloop1:
        mov eax, [edx + CRD_NextRef]
        test eax, eax
        jz .no
        add edx, CRD_Size
    loop .startloop1
        mov eax, 1
    jmp .finish
    .no:
        xor eax, eax
    .finish:
    ret
    endp
proc NewColumn.GetNewCards

    locals
        Card        dd  ?
        Column      dd  ?
        NextCard    dd  ?
        WaitTime    dd  0
    endl

    bts [Flags], IS_NeedAnim
    bts [Flags], IS_CanMove
    dec [NewCount]
    stdcall Column.FindEnd, NewColumn
    mov [Card], eax
    mov [Column], Columns

    mov ecx, 10
    .startloop1:
        push ecx

        mov edx, [Card]
        mov eax, [edx + CRD_PredRef]
        mov [NextCard], eax

        stdcall Column.Replace, [Column], [Card]
        stdcall Column.SetCardsAims, [Column]
        stdcall Card.InitAnimation, [Card], [WaitTime], ANIMATION_TIME
        stdcall Card.Open, [Card]

        mov eax, [NextCard]
        mov [Card], eax
        add [Column], CRD_Size
        add [WaitTime], DEFAULT_ANIM_WAIT

        pop ecx
    loop .startloop1

    ret
    endp
proc SolveColumn.SetCardsAims

    locals
        XCord   dd  ?
        YCord   dd  ?
    endl

    mov eax, [CenterColumnInterval]
    mov [XCord], eax

    mov eax, [RectClient.bottom]
    sub eax, [DownInterval]
    sub eax, [CardHeight]
    mov [YCord], eax

    mov ecx, [SolveCount]
    test ecx, ecx
    jz .finish
    mov eax, [SolveColumn + CRD_NextRef]
    test eax, eax
    jz .finish
    mov edx, eax
    .startloop1:
        push ecx

        mov ecx, 13
        .startloop2:
            mov eax, [XCord]
            mov [edx + CRD_XAim], eax
            mov eax, [YCord]
            mov [edx + CRD_YAim], eax
            mov eax, [edx + CRD_NextRef]
            mov edx, eax
        loop .startloop2

        mov eax, [XCord]
        add eax, [DownInterval]
        mov [XCord], eax

        pop ecx
    loop .startloop1

    .finish:
    ret
    endp
proc SolveColumn.SetPositions

    stdcall SolveColumn.SetCardsAims
    bt [Flags], IS_GameEnd
    jc .finloop1

    mov edx, SolveColumn
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


proc Animation.Append, Card

    stdcall Animation.FindEnd
    mov edx, eax

    mov eax, [Card]
    mov [edx + CRD_NextAnimRef], eax
    mov eax, edx
    mov edx, [Card]
    mov [edx + CRD_PredAnimRef], eax

    ret
    endp
proc Animation.Remove, Card

    locals
        Next    dd  ?
    endl

    mov edx, AnimColumn
    .startloop1:
        mov eax, [edx + CRD_NextAnimRef]
        cmp eax, [Card]
        je .finloop1
        mov edx, eax
    jmp .startloop1
    .finloop1:

    push edx

    mov eax, [edx + CRD_NextAnimRef]
    mov edx, eax
    mov eax, [edx + CRD_NextAnimRef]
    mov [Next], eax
    mov DWORD [edx + CRD_NextAnimRef], 0
    mov DWORD [edx + CRD_PredAnimRef], 0

    pop edx
    mov eax, [Next]
    mov [edx + CRD_NextAnimRef], eax

    test eax, eax
    jz .finish

    push edx
    mov edx, eax
    pop DWORD [edx + CRD_PredAnimRef]
    .finish:
        bts [Flags], IS_NeedBB
    ret
    endp
proc Animation.FindEnd

    mov edx, AnimColumn
    .startloop1:
        mov eax, [edx + CRD_NextAnimRef]
        test eax, eax
        jz .finloop1
        mov edx, eax
    jmp .startloop1
    .finloop1:
    mov eax, edx

    ret
    endp
proc Animation.Run

    mov edx, AnimColumn
    .startloop1:
        mov eax, [edx + CRD_NextAnimRef]
        test eax, eax
        jz .finloop1
        push eax
        stdcall Card.Animation, eax
        pop eax
        mov edx, eax
        bts [Flags], IS_Animation
    jmp .startloop1
    .finloop1:

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
proc Card.InitAnimation, Card, WaitTime, AnimTime

    mov edx, [Card]

    mov eax, [WaitTime]
    test eax, eax
    jz .anim
        bts DWORD [edx + CRD_Info], INF_IsWait
        mov [edx + CRD_AnimWait], eax
    .anim:
        bts DWORD [edx + CRD_Info], INF_IsAnim
        jc .start
        stdcall Animation.Append, edx
    .start:

    ;mov DWORD [edx + CRD_AnimCount], 0
    ;mov eax, [edx + CRD_XAim]
    ;cmp eax, [edx + CRD_XCord]
    ;jne .start
    ;mov eax, [edx + CRD_YAim]
    ;cmp eax, [edx + CRD_YCord]
    ;je .finish


    mov eax, [edx + CRD_XAim]
    sub eax, [edx + CRD_XCord]
    cdq
    mov ecx, [AnimTime]
    idiv ecx
    push eax

    mov edx, [Card]
    mov eax, [edx + CRD_YAim]
    sub eax, [edx + CRD_YCord]
    cdq
    mov ecx, [AnimTime]
    idiv ecx
    push eax

    mov edx, [Card]
    pop DWORD [edx + CRD_YAnim]
    pop DWORD [edx + CRD_XAnim]

    mov eax, [AnimTime]
    mov [edx + CRD_AnimCount], eax

    bts [Flags], IS_Animation

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
            btr DWORD [edx + CRD_Info], INF_IsWait

    .anim:
        dec DWORD [edx + CRD_AnimCount]
        cmp DWORD [edx + CRD_AnimCount], -1
        jne .check
            stdcall Card.EndAnimation, edx
            jmp .finish
        .check:
        cmp DWORD [edx + CRD_AnimCount], 0
        jne .continueanim
            mov eax, [edx + CRD_XAim]
            mov [edx + CRD_XCord], eax
            mov eax, [edx + CRD_YAim]
            mov [edx + CRD_YCord], eax
            jmp .finish
        .continueanim:
        mov eax, [edx + CRD_XAnim]
        add [edx + CRD_XCord], eax
        mov eax, [edx + CRD_YAnim]
        add [edx + CRD_YCord], eax

    .finish:
    ret
    endp
proc Card.EndAnimation, Card

    mov edx, [Card]
    btr DWORD [edx + CRD_Info], INF_IsAnim
    btr DWORD [edx + CRD_Info], INF_IsWait

    mov DWORD [edx + CRD_XAim], 0
    mov DWORD [edx + CRD_YAim], 0
    mov DWORD [edx + CRD_AnimCount], 0
    mov DWORD [edx + CRD_AnimWait], 0
    stdcall Animation.Remove, edx

    ret
    endp
proc Card.CheckCollision, Card, XCord, YCord

    mov edx, [Card]

    mov eax, [edx + CRD_XCord]
    mov [TempRect.left], eax
    add eax, [CardWigth]
    mov [TempRect.right], eax
    mov eax, [edx + CRD_YCord]
    mov [TempRect.top], eax
    add eax, [CardHeight]
    mov [TempRect.bottom], eax

    invoke PtInRect, TempRect, [XCord], [YCord]
    test eax, eax
    jz .finish
        mov eax, [Card]
    .finish:
    ret
    endp


proc Map.Draw, hdc

    invoke CreateCompatibleDC, [hdc]
    mov [hdcBackBuffer], eax
    invoke SelectObject, [hdcBackBuffer], [hBackBuffer]

    invoke BitBlt, [hdc], 0, 0, [RectClient.right], [RectClient.bottom], [hdcBackBuffer], 0, 0, SRCCOPY
    stdcall Map.DrawMovingCards, [hdc]
    stdcall Map.DrawAnimation, [hdc]

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

    stdcall Map.DrawPointCounter, [hdcBackBuffer]
    stdcall Map.DrawNewDecks, [hdcBackBuffer]
    stdcall Map.DrawStaticCards, [hdcBackBuffer]
    stdcall Map.DrawSolveDecks, [hdcBackBuffer]

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
proc Map.DrawAnimation, hdc

    stdcall Animation.FindEnd

    .startloop1:
        cmp eax, [AnimColumn]
        je .finloop1
        mov edx, eax
        bt DWORD [edx + CRD_Info], INF_IsWait
        jnc .next
        push edx
        stdcall Card.Draw, edx, [hdc]
        pop edx
        .next:
        mov eax, [edx + CRD_PredAnimRef]
    jmp .startloop1
    .finloop1:

    mov edx, AnimColumn
    .startloop2:
        mov eax, [edx + CRD_NextAnimRef]
        test eax, eax
        jz .finloop2
        mov edx, eax
        bt DWORD [edx + CRD_Info], INF_IsWait
        jc .startloop2
        push edx
        stdcall Card.Draw, edx, [hdc]
        pop edx
    jmp .startloop2
    .finloop2:

    ret
    endp
proc Map.DrawMovingCards, hdc

    stdcall Column.Draw, MovingColumn, [hdc]

    ret
    endp
proc Map.DrawSolveDecks, hdc

    stdcall Column.Draw, SolveColumn, [hdc]

    ret
    endp
proc Map.DrawNewDecks, hdc

    stdcall Column.Draw, NewColumn, [hdc]

    ret
    endp
proc Map.DrawPointCounter, hdc

    invoke SetTextAlign, [hdc], TA_CENTER + TA_BOTTOM
    invoke SetBkMode, [hdc], TRANSPARENT
    invoke CreateFontIndirect, font
    push eax
    invoke SelectObject, [hdc], eax

    stdcall IntToStr, [Points], _PointsStr + 8

    push [PointsStrLen]
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
