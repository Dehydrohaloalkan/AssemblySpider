format PE GUI 4.0
entry start

include 'win32a.inc'
include 'Macros.asm'

section '.code' code readable executable

stdcall NewColumn.SetPositions
stdcall Game.Start

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
    invoke CreateWindowEx, 0, _class, _title, WS_VISIBLE+WS_SYSMENU+WS_SIZEBOX+WS_MAXIMIZEBOX+WS_MINIMIZEBOX,\
           75, 0, 1850, 1080, NULL, eax, [wc.hInstance], NULL

    invoke SetTimer, eax, GAME_TIMER, 10, NULL
    invoke GetTickCount
    mov [Clock], eax

    stdcall LoadImages
    stdcall CopyStr, font.lfFaceName, _fontname

    invoke DialogBoxParam, [wc.hInstance], GAME_CBOX, HWND_DESKTOP, CheckProc, 0
    ;stdcall Game.Start

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
    cmp [wmsg], WM_TIMER
    je .wmtimer
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


    .defwndproc:
        invoke DefWindowProc, [hwnd], [wmsg], [wparam], [lparam]
        jmp .finish
    .wmsize:
        cmp [hDoubleBuffer], 0
        je .check
        invoke DeleteObject, [hDoubleBuffer]
        .check:
        cmp [hBackBuffer], 0
        je .create
        invoke DeleteObject, [hBackBuffer]
        .create:

        invoke CreateIC, _text, NULL, NULL, NULL
        mov [hdcTemp], eax
        stdcall GetLHparam, [lparam], LowWord, HighWord

        invoke SetRect, RectClient, 0, 0, [LowWord], [HighWord]
        invoke CreateCompatibleBitmap, [hdcTemp], [LowWord], [HighWord]
        mov [hDoubleBuffer], eax
        invoke CreateCompatibleBitmap, [hdcTemp], [LowWord], [HighWord]
        mov [hBackBuffer], eax

        stdcall Game.OnSize, [hwnd]

        invoke DeleteDC, [hdcTemp]
        invoke InvalidateRect, [hwnd], NULL, 0
        jmp .finish
    .wmpaint:
        invoke BeginPaint, [hwnd], ps
        mov [hdcTemp], eax
        invoke CreateCompatibleDC, [hdcTemp]
        mov [hdcDoubleBuffer], eax
        invoke SelectObject, [hdcDoubleBuffer], [hDoubleBuffer]

        stdcall Game.OnPaint, [hwnd]

        invoke BitBlt, [hdcTemp], 0, 0, [RectClient.right], [RectClient.bottom], [hdcDoubleBuffer], 0, 0, SRCCOPY
        invoke DeleteDC, [hdcDoubleBuffer]
        invoke EndPaint, [hwnd], ps
        jmp .finish
    .wmtimer:
        invoke InvalidateRect, [hwnd], NULL, 0
        jmp .finish
    .wmlbuttondown:
        stdcall GetLHparam, [lparam], LowWord, HighWord
        stdcall Game.OnMouseDown, [hwnd]
        jmp .finish
    .wmmousemove:
        stdcall GetLHparam, [lparam], LowWord, HighWord
        stdcall Game.OnMouseMove
        jmp .finish
    .wmlbuttonup:
        stdcall GetLHparam, [lparam], LowWord, HighWord
        stdcall Game.OnMouseUp
        jmp .finish
    .wmgetminmaxinfo:

        mov edx, [lparam]
        add edx, 24
        mov DWORD [edx], 1000
        mov DWORD [edx + 4], 750

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
            stdcall Game.Start, [Seed], 1
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
        ;stdcall DrawPers, eax
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
        bts [Flags], IS_Animation

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

                stdcall Game.Start, [Seed], 1
                jmp .wmclose

            .2suit:
            invoke IsDlgButtonChecked, [hwnd], IDC_2SUIT
            cmp eax, 0
            je .4suit

                stdcall Game.Start, [Seed], 2
                jmp .wmclose

            .4suit:
            invoke IsDlgButtonChecked, [hwnd], IDC_4SUIT
            cmp eax, 0
            je .load

                stdcall Game.Start, [Seed], 4
                jmp .wmclose

            .load:
            invoke IsDlgButtonChecked, [hwnd], IDC_LOAD
            cmp eax, 0
            je .finish

                stdcall Game.Start, [Seed], 1
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

include 'CardEngine.asm'
;include 'CardDrawing.asm'
include 'Personalize.asm'
include 'Data.asm'
include 'resurses.asm'
