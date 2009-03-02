#!/bin/sh
# This file is part of ke-recv
#
# Copyright (C) 2004-2009 Nokia Corporation. All rights reserved.
#
# Contact: Kimmo Hämäläinen <kimmo.hamalainen@nokia.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License 
# version 2 as published by the Free Software Foundation. 
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA

RC=0

/sbin/lsmod | grep g_nokia > /dev/null
if [ $? = 0 ]; then
    logger "$0: removing g_nokia"

    initctl emit G_NOKIA_REMOVE

    PNATD_PID=`pidof pnatd`
    if [ $? = 0 ]; then
        kill $PNATD_PID
    else
        logger "$0: pnatd is not running"
    fi
    OBEXD_PID=`pidof obexd`
    if [ $? = 0 ]; then
        kill $OBEXD_PID
    else
        logger "$0: obexd is not running"
    fi
    SYNCD_PID=`pidof syncd`
    if [ $? = 0 ]; then
        kill $SYNCD_PID
    else
        logger "$0: syncd is not running"
    fi

    sleep 1
    /sbin/rmmod g_nokia
fi

/sbin/lsmod | grep g_file_storage > /dev/null
if [ $? != 0 ]; then
    /sbin/modprobe g_file_storage stall=0 luns=2 removable
    RC=$?
fi

if [ $RC != 0 ]; then
    logger "$0: failed to install g_file_storage"
    exit 1
fi

initctl emit --no-wait G_FILE_STORAGE_READY

if [ $# -gt 1 ]; then
    echo "$0: only one argument supported"
    exit 1
fi

LUN0='/sys/devices/platform/musb_hdrc/gadget/gadget-lun0/file'
LUN1='/sys/devices/platform/musb_hdrc/gadget/gadget-lun1/file'

# check first if the card(s) are already shared
if [ $# = 1 ]; then
    FOUND=0
    if grep -q $1 $LUN0; then
        FOUND=1
    fi
    if grep -q $1 $LUN1; then
        FOUND=1
    fi
    if [ $FOUND = 1 ]; then
        logger "$0: $1 is already USB-shared"
        exit 0
    fi
fi

if [ $# = 1 ]; then
    STR=`cat $LUN0`
    if [ "x$STR" = "x" ]; then
        echo $1 > $LUN0
    else
        echo $1 > $LUN1
    fi
fi

exit 0
