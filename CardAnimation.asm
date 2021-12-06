
PARALLEL_MODE = 1
CONSISTENT_MODE = 2

proc AnimationInit DestColumn, Mode

    locals
        OldX    dd  ?
        OldY    dd  ?
        NewX    dd  ?
        NewY    dd  ?
    endl

    cmp [Mode], CONSISTENT_MODE
    je .consistentmode

        stdcall CopyCards, 0, 10, 11

        mov edx, [DestColumn]
        shl edx, 2
        mov ecx, [ColumnLength + edx]
        dec ecx
        shl edx, 6
        shl ecx, 2
        add edx, ecx
        mov eax, [CardsPositionX + edx]
        mov [NewX], eax
        mov eax, [CardsPositionY + edx]
        mov [NewY], eax
        mov eax, [CardsPositionX + 11 * 4 * 64]
        mov [OldX], eax
        mov eax, [CardsPositionY + 11 * 4 * 64]
        mov [OldY], eax



    .consistentmode:



    ret
    endp
proc Animation



    ret
    endp
proc AnimationEnd



    ret
    endp
