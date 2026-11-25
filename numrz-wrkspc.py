#!/usr/bin/env python3

import ctypes
import sys


def main():
    ws_nms_len = int(sys.argv[1])
    x11 = ctypes.cdll.LoadLibrary("libX11.so.6")
    x11.XOpenDisplay.restype = ctypes.c_void_p
    display = x11.XOpenDisplay(None)
    root = x11.XDefaultRootWindow(ctypes.c_void_p(display))
    prop = x11.XInternAtom(ctypes.c_void_p(display), b"_NET_DESKTOP_NAMES", False)
    utf8 = x11.XInternAtom(ctypes.c_void_p(display), b"UTF8_STRING", False)
    payload = b"\x00".join(str(i).encode() for i in range(1, ws_nms_len + 1)) + b"\x00"
    x11.XChangeProperty(ctypes.c_void_p(display), root, prop, utf8, 8, 0, payload, len(payload))
    x11.XCloseDisplay(ctypes.c_void_p(display))


if __name__ == "__main__":
    main()
