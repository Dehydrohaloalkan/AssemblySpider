GAME_MENU           = 10
GAME_CBOX           = 20
GAME_TIMER          = 30
GAME_ICON           = 40
GAME_ICONS          = 50

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

section '.rsrc' resource data readable
    directory RT_MENU, menus, RT_DIALOG, dialogs, RT_ICON, icons, RT_GROUP_ICON, group_icons
    resource menus, GAME_MENU, LANG_ENGLISH+SUBLANG_DEFAULT, main_menu
    resource dialogs, GAME_CBOX, LANG_NEUTRAL, start_game_dialog
    resource icons, GAME_ICON, LANG_NEUTRAL, main_icon
    resource group_icons, GAME_ICONS, LANG_NEUTRAL, main_icons


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

    icon main_icons, main_icon, 'For Compile\icons8_clubs2.ico'
