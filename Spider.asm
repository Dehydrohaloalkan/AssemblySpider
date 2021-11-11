format PE GUI 4.0
entry start

include 'win32a.inc'

section '.code' code readable executable

start:
    invoke GetModuleHandle, 0
    mov [wc.hInstance], eax
    invoke LoadIcon, 0, IDI_APPLICATION
    mov [wc.hIcon], eax
    invoke  LoadCursor, 0, IDC_ARROW
    mov [wc.hCursor], eax

    invoke RegisterClass, wc
    invoke CreateWindowEx, 0, _class, _title, WS_VISIBLE+WS_SYSMENU+WS_SIZEBOX+WS_MAXIMIZEBOX+WS_MINIMIZEBOX,\
           75, 0, 1850, 1080, NULL, NULL, [wc.hInstance], NULL

    stdcall LoadImages
    stdcall SetColumnsLenght
    stdcall SetInitArrayDBG
    stdcall SetCardsStartInfo

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

    .defwndproc:
        invoke DefWindowProc, [hwnd], [wmsg], [wparam], [lparam]
        jmp .finish

    .wmsize:
        mov eax, [hbmpbuffer]
        cmp eax, 0
        je .create
        invoke DeleteObject, eax

        .create:
        invoke CreateIC, _text, NULL, NULL, NULL
        mov [hdc], eax

        stdcall GetLHparam, [lparam], LowWord, HighWord
        invoke CreateCompatibleBitmap, [hdc], [LowWord], [HighWord]
        mov [hbmpbuffer], eax

        invoke SetRect, RectClient, 0, 0, [LowWord], [HighWord]

        stdcall SetMetrics

        invoke DeleteDC, [hdc]
        invoke InvalidateRect, [hwnd], NULL, 0
        jmp .finish

    .wmpaint:

        stdcall SetCardsPositions

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
            jmp .finish

        .newdeck:
            stdcall CheckEmptyColums
            cmp eax, 0
            je .nomove
            stdcall AddNewCards
            dec [NewDecksCount]
            jmp .finish

        .nomove:
            jmp .finish

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

        stdcall CheckPlacing, [TempColumn]
        cmp eax, 0
        je .moveback

            stdcall CopyCards, 0, 10, [TempColumn]
            jmp .theend

        .moveback:
            stdcall CopyCards, 0, 10, [OldColumn]

        .theend:
            stdcall PostCheckCards
            invoke InvalidateRect, [hwnd], NULL, 0

        jmp .finish

    .wmgetminmaxinfo:

        mov edx, [lparam]
        add edx, 24
        mov DWORD [edx], 1200
        mov DWORD [edx + 4], 800

        jmp .finish

    .wmdestroy:
        invoke PostQuitMessage,0
        xor eax, eax

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

proc LoadImages

    invoke LoadImage, [wc.hInstance], _texturename, IMAGE_BITMAP, CardResolutionX*14, CardResolutionY, LR_LOADFROMFILE
    mov [hCards], eax

    ret
    endp

include 'CardEngine.asm'
include 'Data.asm'
