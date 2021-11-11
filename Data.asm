
CardResolutionX = 71
CardResolutionY = 96

section '.cardst' data readable writeable

    _texturename       TCHAR   'res\cards_hearts.bmp', 0

    hCards      dd      ?

section '.sdata' data readable writeable

    _class      TCHAR 'MainForm', 0
    _title      TCHAR 'Spider', 0
    _text       TCHAR 'DISPLAY', 0
    _name       TCHAR 'res\Card.bmp', 0
    _winstr     TCHAR 'you win', 0
    winstrlen   dd    7

    wc      WNDCLASS 0, WindowProc, 0, 0, NULL, NULL, NULL, COLOR_BTNFACE + 1, NULL, _class
    msg     MSG
    font    LOGFONT 300, 0, 0, 0, 0, 0, 0, 0, DEFAULT_CHARSET, 0, 0, 0, DEFAULT_PITCH, 0

    hbmpbuffer      dd      ?
    hdc             dd      ?
    hdcMem          dd      ?
    HighWord        dd      ?
    LowWord         dd      ?
    RandPr          dd      ?
    RectClient      RECT
    ps              PAINTSTRUCT

section '.gdata' data readable writeable

    CardHeight              dd      ?
    CardWigth               dd      ?
    ColumnInterval          dd      11      dup     40
    CenterColumnInterval    dd      ?
    Indent                  dd      ?
    DownInterval            dd      ? 

    InitArray               dd      104     dup     ?
    InitPt                  dd      0
    SolvingDecksCount       dd      0
    NewDecksCount           dd      5

    saveX           dd      ?
    saveY           dd      ?
    TempRect        RECT
    TempColumn      dd      ?
    TempIndex       dd      ?
    OldColumn       dd      ?


    IsMouseDown     dd      ?
    ColumnLength    dd      11      dup     ?
    CardsPositionX  dd      11*64   dup     ?
    CardsPositionY  dd      11*64   dup     ?
    CardInfo        dd      11*64   dup     ?

section '.idata' import data readable writeable

    library kernel32, 'KERNEL32.DLL', \
            user32,   'USER32.DLL', \
            gdi32,    'GDI32.DLL',\
            msimg32,  'msimg32.dll'


    import msimg32,\
       TransparentBlt, 'TransparentBlt'



    include 'api\kernel32.inc'
    include 'api\user32.inc'
    include 'api\gdi32.inc'
