



cmp [wmsg], WM_KEYDOWN
je .wmkeydown

.wmlbuttondown:
    bts [Flags], IS_MOUSE_DOWN
    invoke SetCapture, [hwnd]

    push TempColumn
    push TempIndex
        stdcall GetLHparam, [lparam], LowWord, HighWord
        mov eax, [HighWord]
        mov [saveY], eax
    push eax
        mov eax, [LowWord]
        mov [saveX], eax
    push eax
    stdcall FindCard

    cmp eax, 0
    je .nomove
    cmp eax, 2
    je .newdeck

        stdcall CheckMoving, [TempIndex], [TempColumn]
        cmp eax, 0
        je .nomove
        mov eax, [TempColumn]
        mov [OldColumn], eax
        stdcall CopyCards, [TempIndex], [TempColumn], 10
        jmp .lastaction

    .newdeck:
        stdcall CheckEmptyColums
        cmp eax, 0
        je .nomove
        stdcall AddNewCards
        stdcall SaveInfo, 0, 0, 0, NEW_CODE
        stdcall SetCardsIntervals
        stdcall SetCardsPositions
        dec [NewDecksCount]
        jmp .lastaction

    .nomove:
        jmp .finish

    .lastaction:
        CreateBackBuffer
        jmp .finish
.wmmousemove:
    bt [Flags], IS_MOUSE_DOWN
    jnc .finish
    stdcall GetLHparam, [lparam], LowWord, HighWord

    mov eax, [HighWord]
    sub eax, [saveY]
    push eax
    mov eax, [LowWord]
    sub eax, [saveX]
    push eax
    stdcall MoveCards

    mov eax, [LowWord]
    mov [saveX], eax
    mov eax, [HighWord]
    mov [saveY], eax

    invoke InvalidateRect, [hwnd], NULL, 0
    jmp .finish
.wmlbuttonup:
    btr [Flags], IS_MOUSE_DOWN
    invoke ReleaseCapture

    push TempColumn
        stdcall GetLHparam, [lparam], LowWord, HighWord
        mov eax, [HighWord]
        mov [saveY], eax
    push eax
        mov eax, [LowWord]
        mov [saveX], eax
    push eax
    stdcall FindColumn

    test eax, eax
    jz .moveback

    mov eax, [ColumnLength + 10 * 4]
    test eax, eax
    jz .theend

    stdcall CheckPlacing, [TempColumn]
    test eax, eax
    jz .moveback

        mov edx, [TempColumn]
        shl edx, 2
        mov eax, [ColumnLength + edx]
        push eax
        stdcall CopyCards, 0, 10, [TempColumn]
        mov eax, [TempColumn]
        cmp eax, [OldColumn]
        pop eax

        je .theend
        dec [Points]
        cmp [Points], -1
        jne .save
            mov [Points], 0
        .save:
        stdcall SaveInfo, [TempColumn], [OldColumn], eax, 0
        jmp .theend

    .moveback:
        stdcall CopyCards, 0, 10, [OldColumn]

    .theend:
        stdcall PostCheckCards
        stdcall SetCardsIntervals
        stdcall SetCardsPositions
        CreateBackBuffer
        invoke InvalidateRect, [hwnd], NULL, 0
    jmp .finish

.wmtimer:
    btr [Flags], IS_NEED_REPAINT
    jnc .finish
    CreateBackBuffer
    invoke InvalidateRect, [hwnd], NULL, 0
    jmp .finish
.wmkeydown:

    cmp [wparam], 05Ah
    je .zdown

    .zdown:

        stdcall MoveBack
        stdcall SetCardsIntervals
        stdcall SetCardsPositions
        CreateBackBuffer
        bts [Flags], IS_NEED_REPAINT
        jmp .lastmove

    .lastmove:
    xor eax, eax
    jmp .finish
