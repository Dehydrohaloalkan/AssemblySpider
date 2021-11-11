
CardResolutionX = 142
CardResolutionY = 192

section '.cardst' data readable writeable

    _name0      TCHAR   'res\Card0.bmp', 0
    _name1      TCHAR   'res\Card1.bmp', 0
    _name2      TCHAR   'res\Card2.bmp', 0
    _name3      TCHAR   'res\Card3.bmp', 0
    _name4      TCHAR   'res\Card4.bmp', 0
    _name5      TCHAR   'res\Card5.bmp', 0
    _name6      TCHAR   'res\Card6.bmp', 0
    _name7      TCHAR   'res\Card7.bmp', 0
    _name8      TCHAR   'res\Card8.bmp', 0
    _name9      TCHAR   'res\Card9.bmp', 0
    _name10     TCHAR   'res\Card10.bmp', 0
    _name11     TCHAR   'res\Card11.bmp', 0
    _name12     TCHAR   'res\Card12.bmp', 0
    _name13     TCHAR   'res\Card13.bmp', 0

    hCards      dd      14 dup ?

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

    CardHeight              dd      190
    CardWigth               dd      140
    CenterColumnInterval    dd  ?
    ColumnInterval          dd      11      dup     40
    InitArray               dd      104     dup     ?
    InitPt                  dd      0
    InitFlag                dd      0
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
