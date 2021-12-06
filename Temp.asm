

cmp [wmsg], WM_GETMINMAXINFO
je .wmgetminmaxinfo
cmp [wmsg], WM_COMMAND
je .wmcommand

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
.wmgetminmaxinfo:

    mov edx, [lparam]
    add edx, 24
    mov DWORD [edx], 1000
    mov DWORD [edx + 4], 750

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
.wmcommand:

    mov eax, [wparam]
    and eax, 0FFFFh

    cmp eax, IDM_NEW
    je .idmnew
    cmp eax, IDM_RESTART
    je .idmrestart
    cmp eax, IDM_EXIT
    je .idmexit
    cmp eax, IDM_PERS
    je .idmpers

    .idmnew:
        invoke DialogBoxParam, [wc.hInstance], GAME_CBOX, HWND_DESKTOP, CheckProc, 0
        jmp .finish
    .idmrestart:
        stdcall GameStart, [Seed], 1
        jmp .finish
    .idmpers:
        mov [RectPers.top], 0
        mov [RectPers.left], 0
        mov [RectPers.right], PERS_X
        mov [RectPers.bottom], PERS_Y

        invoke AdjustWindowRect, RectPers, WS_VISIBLE+WS_SYSMENU, 1

        mov eax, [RectPers.left]
        sub [RectPers.right], eax
        mov eax, [RectPers.top]
        sub [RectPers.bottom], eax

        invoke CreateWindowEx, 0, _perscl, _perstitle, WS_VISIBLE+WS_SYSMENU,\
               CW_USEDEFAULT, CW_USEDEFAULT, [RectPers.right], [RectPers.bottom], [hwnd], NULL, [pc.hInstance], NULL

        mov [RectPers.top], 0
        mov [RectPers.left], 0
        mov [RectPers.right], PERS_X
        mov [RectPers.bottom], PERS_Y

        jmp .finish
    .idmexit:




proc CheckProc uses ebx esi edi, hwnd, wmsg, wparam, lparam
    cmp [wmsg], WM_CLOSE
    je .wmclose
    cmp [wmsg], WM_COMMAND
    je .wmcommand

    .defwndproc:
        invoke DefWindowProc, [hwnd], [wmsg], [wparam], [lparam]
        jmp .finish
    .wmcommand:

        invoke GetTickCount
        ;mov [Seed], eax
        mov [Seed], 1

        cmp [wparam], IDB_OKBUTTON
        je .idbokbutton
        cmp [wparam], IDB_CANCELBUTTON
        je .wmclose
        jmp .finish

        .idbokbutton:

            invoke IsDlgButtonChecked, [hwnd], IDC_1SUIT
            cmp eax, 0
            je .2suit

                stdcall GameStart, [Seed], 1
                jmp .wmclose

            .2suit:
            invoke IsDlgButtonChecked, [hwnd], IDC_2SUIT
            cmp eax, 0
            je .4suit

                stdcall GameStart, [Seed], 2
                jmp .wmclose

            .4suit:
            invoke IsDlgButtonChecked, [hwnd], IDC_4SUIT
            cmp eax, 0
            je .load

                stdcall GameStart, [Seed], 4
                jmp .wmclose

            .load:
            invoke IsDlgButtonChecked, [hwnd], IDC_LOAD
            cmp eax, 0
            je .finish

                stdcall GameStart, [Seed], 1
                jmp .wmclose

        jmp .finish
    .wmclose:
        invoke EndDialog, [hwnd], 0

    .finish:
        ret
    endp
