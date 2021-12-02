macro CreateBackBuffer
{
    invoke BeginPaint, [hwnd], ps
    stdcall MakeBackBuffer, eax
    invoke EndPaint, [hwnd], ps
}
