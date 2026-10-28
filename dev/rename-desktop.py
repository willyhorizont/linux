#!/usr/bin/env python3

import ctypes
import subprocess

num_desktops = int(subprocess.check_output(["xdotool", "get_num_desktops"]).strip())

names = [str(i) for i in range(1, num_desktops + 1)]

x11 = ctypes.cdll.LoadLibrary("libX11.so.6")
display = x11.XOpenDisplay(None)

if display:
    root = x11.XDefaultRootWindow(display)
    
    atom_name = b"_NET_DESKTOP_NAMES"
    property_atom = x11.XInternAtom(display, atom_name, False)
    utf8_string_atom = x11.XInternAtom(display, b"UTF8_STRING", False)
    
    encoded_names = b"\x00".join([name.encode('utf-8') for name in names]) + b"\x00"
    
    x11.XChangeProperty(display, root, property_atom, utf8_string_atom, 8, 0, encoded_names, len(encoded_names))
    
    x11.XFlush(display)
    x11.XCloseDisplay(display)
