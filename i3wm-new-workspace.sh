#!/bin/bash

NU_WRKSPC=$(i3-msg -t get_workspaces | jq '[.[].num] | max + 1')

i3-msg workspace $NU_WRKSPC
