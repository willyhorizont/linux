#!/usr/bin/env python3
import sys


def main():
    CORE_TEXT = "SPACE AVAILABLE SPACE AVAILABLE "
    CORE_LEN = len(CORE_TEXT)

    pos = 0
    try:
        with open('/proc/uptime', 'r') as fh:
            ln = fh.readline()
            seconds_int = int(ln.split('.')[0])
            pos = seconds_int % CORE_LEN
    except Exception:
        pass

    long_txt = CORE_TEXT + CORE_TEXT

    moving_part = long_txt[pos:pos+32]

    rr = f'  {moving_part} '

    sys.stdout.write(rr)


if __name__ == "__main__":
    main()
