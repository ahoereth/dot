#!/bin/bash
sudo python2 $DOT_PATH/juniper-vpn-py/juniper-vpn.py \
    --host vpn-e.serv.uos.de \
    --realm uos \
    --stdin DSID=%DSID% \
    openconnect \
        --juniper %HOST% \
        --cookie-on-stdin