#!/bin/bash
sudo $DOT_PATH/juniper-vpn-py/.venv/bin/python $DOT_PATH/juniper-vpn-py/juniper-vpn.py \
    --host vpn-x.serv.uos.de \
    --realm uos \
    --stdin DSID=%DSID% \
    openconnect \
        --juniper %HOST% \
        --cookie-on-stdin
