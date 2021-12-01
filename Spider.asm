format PE GUI 4.0
entry start

include 'win32a.inc'

section '.code' code readable executable

start:
    invoke GetModuleHandle, 0
    mov [wc.hInstance], eax
    mov [pc.hInstance], eax
    invoke LoadIcon, [wc.hInstance], GAME_ICONS
    mov [wc.hIcon], eax
    mov [pc.hIcon], eax
    invoke  LoadCursor, 0, IDC_ARROW
    mov [wc.hCursor], eax
    mov [pc.hCursor], eax

    invoke RegisterClass, wc
    invoke RegisterClass, pc
    invoke LoadMenu, [wc.hInstance], GAME_MENU
    mov [hmenu], eax
    invoke CreateWindowEx, 0, _class, _title, WS_VISIBLE+WS_SYSMENU+WS_SIZEBOX+WS_MAXIMIZEBOX+WS_MINIMIZEBOX,\
           75, 0, 1850, 1080, NULL, eax, [wc.hInstance], NULL
    mov [hwndMain], eax

    invoke SetTimer, eax, GAME_TIMER, 10, NULL

    stdcall LoadImages
    stdcall CopyStr, font.lfFaceName, _fontname

    invoke DialogBoxParam, [wc.hInstance], GAME_CBOX, HWND_DESKTOP, CheckProc, 0

    msg_loop:
        invoke GetMessage, msg, NULL, 0, 0
        cmp eax, 1
        jb end_loop
        jne msg_loop
        invoke TranslateMessage, msg
        invoke DispatchMessage, msg
        jmp msg_loop

    end_loop:
        invoke ExitProcess, [msg.wParam]

proc WindowProc uses ebx esi edi, hwnd, wmsg, wparam, lparam
    cmp [wmsg], WM_DESTROY
    je .wmdestroy
    cmp [wmsg], WM_PAINT
    je .wmpaint
    cmp [wmsg], WM_SIZE
    je .wmsize
    cmp [wmsg], WM_LBUTTONDOWN
    je .wmlbuttondown
    cmp [wmsg], WM_MOUSEMOVE
    je .wmmousemove
    cmp [wmsg], WM_LBUTTONUP
    je .wmlbuttonup
    cmp [wmsg], WM_GETMINMAXINFO
    je .wmgetminmaxinfo
    cmp [wmsg], WM_COMMAND
    je .wmcommand
    cmp [wmsg], WM_TIMER
    je .wmtimer
    cmp [wmsg], WM_KEYDOWN
    je .wmkeydown

    .defwndproc:
        invoke DefWindowProc, [hwnd], [wmsg], [wparam], [lparam]
        jmp .finish
    .wmsize:
        cmp [hbmpbuffer], 0
        je .check
        invoke DeleteObject, [hbmpbuffer]

        .check:
        cmp [hBackBuffer], 0
        je .create
        invoke DeleteObject, [hBackBuffer]

        .create:
        invoke CreateIC, _text, NULL, NULL, NULL
        mov [hdc], eax

        stdcall GetLHparam, [lparam], LowWord, HighWord

        invoke CreateCompatibleBitmap, [hdc], [LowWord], [HighWord]
        mov [hbmpbuffer], eax
        invoke CreateCompatibleBitmap, [hdc], [LowWord], [HighWord]
        mov [hBackBuffer], eax

        invoke SetRect, RectClient, 0, 0, [LowWord], [HighWord]

        stdcall SetMetrics
        stdcall SetCardsIntervals

        invoke DeleteDC, [hdc]
        stdcall SetCardsIntervals
        stdcall SetCardsPositions

        invoke BeginPaint, [hwnd], ps
        stdcall MakeBackBuffer, eax
        invoke EndPaint, [hwnd], ps

        invoke InvalidateRect, [hwnd], NULL, 0
        jmp .finish
    .wmpaint:
        invoke BeginPaint, [hwnd], ps
        mov [hdc], eax

        invoke CreateCompatibleDC, [hdc]
        mov [hdcMem], eax

        invoke SelectObject, [hdcMem], [hbmpbuffer]

        stdcall DrawMap, [hdcMem]

        invoke BitBlt, [hdc], 0, 0, [RectClient.right], [RectClient.bottom], [hdcMem], 0, 0, SRCCOPY

        invoke DeleteDC, [hdcMem]
        invoke EndPaint, [hwnd], ps
        jmp .finish
    .wmlbuttondown:
        mov [IsMouseDown], 1
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
            invoke BeginPaint, [hwnd], ps
            stdcall MakeBackBuffer, eax
            invoke EndPaint, [hwnd], ps
    .wmmousemove:
        mov eax, [IsMouseDown]
        cmp eax, 0
        je .finish
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
        mov [IsMouseDown], 0
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
        cmp eax, 0
        je .moveback

        mov eax, [ColumnLength + 10 * 4]
        cmp eax, 0
        je .theend

        stdcall CheckPlacing, [TempColumn]
        cmp eax, 0
        je .moveback

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

            invoke BeginPaint, [hwnd], ps
            stdcall MakeBackBuffer, eax
            invoke EndPaint, [hwnd], ps

            invoke InvalidateRect, [hwnd], NULL, 0

        jmp .finish
    .wmgetminmaxinfo:

        mov edx, [lparam]
        add edx, 24
        mov DWORD [edx], 1200
        mov DWORD [edx + 4], 800

        jmp .finish
    .wmtimer:
        cmp [IsNeedRepaint], 0
        je .finish
        invoke BeginPaint, [hwnd], ps
        stdcall MakeBackBuffer, eax
        invoke EndPaint, [hwnd], ps
        invoke InvalidateRect, [hwnd], NULL, 0
        mov [IsNeedRepaint], 0
        jmp .finish
    .wmkeydown:

        cmp [wparam], 05Ah
        je .zdown

        .zdown:

            ;bt [lparam], 24
            ;jnc .lastmove
            stdcall MoveBack
            stdcall SetCardsIntervals
            stdcall SetCardsPositions
            mov [IsNeedRepaint], 1
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

            mov [hwndPers], eax
            jmp .finish
        .idmexit:
    .wmdestroy:
        invoke PostQuitMessage,0
        xor eax, eax

    .finish:
        ret
    endp

proc PersProc uses ebx esi edi, hwnd, wmsg, wparam, lparam
    cmp [wmsg], WM_PAINT
    je .wmpaint
    cmp [wmsg], WM_LBUTTONDOWN
    je .wmlbuttondown

    .defwndproc:
        invoke DefWindowProc, [hwnd], [wmsg], [wparam], [lparam]
        jmp .finish
    .wmpaint:
        invoke BeginPaint, [hwnd], ps
        stdcall DrawPers, eax
        invoke EndPaint, [hwnd], ps
        jmp .finish
    .wmlbuttondown:

        stdcall GetLHparam, [lparam], LowWord, HighWord
        mov eax, [HighWord]
        mov [saveY], eax
            push eax
        mov eax, [LowWord]
        mov [saveX], eax
            push eax
        stdcall FindBackCard

        mov [BackCardIndex], eax
        mov [IsNeedRepaint], 1
        ;invoke InvalidateRect, [hwndMain], RectClient, 1
        ;invoke SendMessage, [hwndMain], WM_PAINT, 0, 0

        jmp .finish

    .finish:
        ret
    endp

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

proc GetLHparam, LH, L, H

    mov eax, [LH]
    and eax, 0FFFFh
    mov edx, [L]
    mov [edx], eax

    mov eax, [LH]
    shr eax, 16
    mov edx, [H]
    mov [edx], eax

    ret
    endp
proc LoadImages uses edi

    invoke LoadImage, [wc.hInstance], _Texture, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
    mov [hTextures], eax

    ret
    endp

include 'CardEngine.asm'
include 'CardDrawing.asm'
include 'Personalize.asm'
include 'Data.asm'
