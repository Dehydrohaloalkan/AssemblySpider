
CardResolutionX = 71 * 2
CardResolutionY = 96 * 2
MIXER           = 100

section '.cardst' data readable writeable

    _Texture            TCHAR   'res\cards.bmp', 0
    hTextures           dd      ?
    TextureLine         dd      ?
    TextureIndex        dd      ?
    BackCardIndex       dd      1

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

    hmenu           dd      ?
    hbmpbuffer      dd      ?
    hdc             dd      ?
    hdcMem          dd      ?
    HighWord        dd      ?
    LowWord         dd      ?
    RandPr          dd      ?
    RectClient      RECT
    ps              PAINTSTRUCT

section '.gdata' data readable writeable

    IsGame                  dd      ?

    CardHeight              dd      ?
    CardWigth               dd      ?
    CenterColumnInterval    dd      ?
    Indent                  dd      ?
    DownInterval            dd      ?

    InitArray               dd      104     dup     ?
    InitPt                  dd      ?
    SolvingDecksCount       dd      ?
    NewDecksCount           dd      ?

    saveX           dd      ?
    saveY           dd      ?
    TempRect        RECT
    TempColumn      dd      ?
    TempIndex       dd      ?
    OldColumn       dd      ?


    IsMouseDown         dd      ?
    ColumnLength        dd      11      dup     ?
    CardsPositionX      dd      11*64   dup     ?
    CardsPositionY      dd      11*64   dup     ?
    CardInfo            dd      11*64   dup     ?
    CardAfterInterval   dd      11*64   dup     ?

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

IDM_NEW = 101
IDM_RESTART = 102
IDM_EXIT = 103
IDM_ABOUT = 104
GAME_MENU = 10

section '.rsrc' resource data readable
    directory RT_MENU, menus
    resource menus, GAME_MENU, LANG_ENGLISH+SUBLANG_DEFAULT, main_menu
    menu main_menu
    menuitem '&Game', 0, MFR_POPUP
        menuitem '&New', IDM_NEW
        menuitem '&Restart', IDM_RESTART
        menuseparator
        menuitem 'E&xit', IDM_EXIT,MFR_END
    menuitem '&Help', 0, MFR_POPUP + MFR_END
        menuitem '&About...', IDM_ABOUT, MFR_END
