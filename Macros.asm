macro MCreateBackBuffer
{
    invoke BeginPaint, [hwnd], ps
    stdcall Map.CreateBackBuffer, eax
    invoke EndPaint, [hwnd], ps
}

macro MGetCardSuit Info
{
    mov eax, Info
    and eax, 11b
}

macro MSetCardsuit Info, Suit
{
    mov eax, Suit
    add Info, eax
}

macro MGetCardNominal Info
{
    mov eax, Info
    shr eax, 2
    and eax, 1111b
}

macro MSetCardNominal Info, Nominal
{
    mov eax, Nominal
    shl eax, 2
    add Info, eax
}

macro MGetCardColumn Info
{
    mov eax, Info
    shr eax, 6
    and eax, 1111b
}

macro MSetCardcolumn Info, Column
{
    mov eax, Column
    shl eax, 6
    add Info, eax
}
