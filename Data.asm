
CARD_RESOLUTION_X   = 71 * 2
CARD_RESOLUTION_Y   = 96 * 2
MIXER               = 500
ANIMATION_TIME      = 8

GAME_BCK_COLOR      = 0053771Bh
PERS_BCK_COLOR      = 0042CDFFh

PERS_X_COUNT        = 4
PERS_Y_COUNT        = 3
PERS_CARD_WIGTH     = 71
PERS_CARD_HEIGHT    = 96
PERS_INDENT         = 15
PERS_FONT           = 20
PERS_X              = PERS_X_COUNT * PERS_CARD_WIGTH + (PERS_X_COUNT + 1) * PERS_INDENT
PERS_Y              = PERS_Y_COUNT * PERS_CARD_HEIGHT + (PERS_Y_COUNT + 1) * PERS_INDENT + PERS_FONT



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

    _Texture            TCHAR   'res\cards.bmp', 0
    BackCardIndex       dd      1
    _PointsStr          db      'Points:    ', 0, 0
    PointsStrLen        dd      ?
    hTextures           dd      ?

    hDoubleBuffer       dd      ?
    hBackBuffer         dd      ?
    hdcDoubleBuffer     dd      ?
    hdcBackBuffer       dd      ?
    hdcTemp             dd      ?

    HighWord            dd      ?
    LowWord             dd      ?
    RectClient          RECT
    RectPers            RECT
    TempRect            RECT
    ps                  PAINTSTRUCT

section '.gdata' data readable writeable

    ; Card Structure
    Cards           dd  104 * CRD_SizeD dup ?
        CRD_Info        = 0
            ; Suit      0 - 1
            ; Nominal   2 - 5
            ; Flags     10 - 14
            INF_IsClose     = 10
            INF_IsOnBoard   = 11
            INF_IsAnim      = 12
            INF_IsPop       = 13
            INF_IsMove      = 14
            INF_IsWait      = 15
        CRD_XCord       = 4
        CRD_YCord       = 8
        CRD_XAnim       = 12
        CRD_YAnim       = 16
        CRD_AnimCount   = 20
        CRD_AnimWait    = 24
        CRD_XAim        = 28
        CRD_YAim        = 32
        CRD_XTexture    = 36
        CRD_YTexture    = 40
        CRD_Indent      = 44
        CRD_PredRef     = 48
        CRD_NextRef     = 52
        CRD_NextAnimRef = 56
        CRD_Column      = 60
        CRD_OldColumn   = 64

        CRD_SizeD       = 20
        CRD_Size        = CRD_SizeD * 4

    ; Columns
    Columns         dd  10 * CRD_SizeD dup ?
    MovingColumn    dd  1 * CRD_SizeD dup ?
    AnimColumn      dd  1 * CRD_SizeD dup ?

    IS_GAME                 =       0
    IS_Animation            =       1
    IS_MOUSE_DOWN           =       2
    Flags                   dd      0
    Clock                   dd      ?

    ; Game Information
    Seed                    dd      ?
    RandPr                  dd      ?
    Points                  dd      500
    saveX                   dd      ?
    saveY                   dd      ?
    SolvingDecksCount       dd      ?
    SolvingInformation      dd      8       dup     ?
    NewDecksCount           dd      ?

    ; Metrics
    CardHeight              dd      ?
    CardWigth               dd      ?
    CenterColumnInterval    dd      ?
    Indent                  dd      ?
    DownInterval            dd      ?

    SaveArray       dd  1000 dup ?
    SavePointer     dd  ?
