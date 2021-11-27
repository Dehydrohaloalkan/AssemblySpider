
CARD_RESOLUTION_X   = 71 * 2
CARD_RESOLUTION_Y   = 96 * 2
MIXER               = 500

GAME_BCK_COLOR      = 0053771Bh
PERS_BCK_COLOR      = 0042CDFFh

PERS_X_COUNT        = 4
PERS_Y_COUNT        = 3
PERS_INDENT         = 30
PERS_FONT           = 40
PERS_X              = PERS_X_COUNT * CARD_RESOLUTION_X + (PERS_X_COUNT + 1) * PERS_INDENT
PERS_Y              = PERS_Y_COUNT * CARD_RESOLUTION_Y + (PERS_Y_COUNT + 1) * PERS_INDENT + PERS_FONT

section '.cardst' data readable writeable

    _Texture            TCHAR   'res\cards.bmp', 0
    hTextures           dd      ?
    TextureLine         dd      ?
    TextureIndex        dd      ?
    BackCardIndex       dd      0

section '.sdata' data readable writeable

    _class      TCHAR 'MainForm', 0
    _perscl     TCHAR 'PersForm', 0
    _title      TCHAR 'Spider', 0
    _perstitle  TCHAR 'Personalize', 0
    _text       TCHAR 'DISPLAY', 0
    _name       TCHAR 'res\Card.bmp', 0

    _fontname   TCHAR 'Ink Free', 0
    _persfont   TCHAR 'Consolas', 0

    _persstr    TCHAR 'Choosing a card back:', 0
    _winstr     TCHAR 'You Win!', 0
    winstrlen   dd    8

    wc          WNDCLASS 0, WindowProc, 0, 0, NULL, NULL, NULL, COLOR_BTNFACE + 1, NULL, _class
    pc          WNDCLASS 0, PersProc, 0, 0, NULL, NULL, NULL, COLOR_BTNFACE + 1, NULL, _perscl
    msg         MSG
    font        LOGFONT 35, 0, 0, 0, 0, 0, 0, 0, DEFAULT_CHARSET, 0, 0, 0, DEFAULT_PITCH, 0

    hwndMain        dd      ?
    hwndPers        dd      ?

    hmenu           dd      ?
    hbmpbuffer      dd      ?
    hdc             dd      ?
    hdcMem          dd      ?
    HighWord        dd      ?
    LowWord         dd      ?
    RandPr          dd      ?
    RectClient      RECT
    RectPers        RECT
    ps              PAINTSTRUCT

section '.gdata' data readable writeable

    IsNeedRepaint           dd      0
    IsGame                  dd      0
    Seed                    dd      ?
    Points                  dd      ?
    PointsStr               db      'Points: 500', 0, 0
    PointsStrLen            dd      ?

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

GAME_MENU           = 10
GAME_CBOX           = 20
GAME_TIMER          = 30

IDM_NEW             = 101
IDM_RESTART         = 102
IDM_EXIT            = 103
IDM_ABOUT           = 104
IDM_PERS            = 105

IDC_GETSUITNUMBER   = 201
IDC_1SUIT           = 202
IDC_2SUIT           = 203
IDC_4SUIT           = 204
IDC_LOAD            = 205
IDB_OKBUTTON        = 206
IDB_CANCELBUTTON    = 207

section '.rsrc' resource data readable
    directory RT_MENU, menus, RT_DIALOG, dialogs
    resource menus, GAME_MENU, LANG_ENGLISH+SUBLANG_DEFAULT, main_menu
    resource dialogs, GAME_CBOX, LANG_NEUTRAL, start_game_dialog

    menu main_menu
        menuitem '&Game', 0, MFR_POPUP
            menuitem '&New', IDM_NEW
            menuitem '&Restart', IDM_RESTART
            menuseparator
            menuitem 'E&xit', IDM_EXIT,MFR_END
        menuitem '&Help', 0, MFR_POPUP
            menuitem '&About...', IDM_ABOUT, MFR_END
        menuitem '&Personalize', IDM_PERS, MFR_END

    dialog start_game_dialog, 'New Game', 0, 0, 97, 110, DS_CENTER+DS_SETFONT, 0, NULL, 1
        dialogitem 'Button', 'Number of card suits', IDC_GETSUITNUMBER, 5, 5, 85, 55, WS_VISIBLE+BS_GROUPBOX
            dialogitem 'Button', '&1 suit', IDC_1SUIT, 10, 17, 60, 10, WS_VISIBLE+BS_AUTORADIOBUTTON+WS_GROUP
            dialogitem 'Button', '&2 suits', IDC_2SUIT, 10, 27, 60, 10, WS_VISIBLE+BS_AUTORADIOBUTTON
            dialogitem 'Button', '&4 suits', IDC_4SUIT, 10, 37, 60, 10, WS_VISIBLE+BS_AUTORADIOBUTTON
            dialogitem 'Button', '&Load Old Game', IDC_LOAD, 10, 47, 70, 10, WS_VISIBLE+BS_AUTORADIOBUTTON
        dialogitem 'Button', '&OK', IDB_OKBUTTON , 5, 60, 85, 15, WS_VISIBLE
        dialogitem 'Button', '&Cancel', IDB_CANCELBUTTON , 5, 75, 85, 15, WS_VISIBLE
    enddialog
