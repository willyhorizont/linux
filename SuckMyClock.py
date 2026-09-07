#!/usr/bin/env python3
import datetime
import calendar


def main():
    now = datetime.datetime.now()

    month_num = now.strftime("%m")
    day_num = now.strftime("%d")
    year = now.year
    month_int = now.month

    total_days = calendar.monthrange(year, month_int)[1]

    date_string = now.strftime("%a, %d %b %Y")
    time_24 = now.strftime("%H:%M:%S")
    time_12 = now.strftime("%I:%M:%S %p")

    simple_clock = f"| {month_num}/12 months | {day_num}/{total_days} days | {date_string} | {time_24} | {time_12} "

    print(simple_clock)


if __name__ == "__main__":
    main()

