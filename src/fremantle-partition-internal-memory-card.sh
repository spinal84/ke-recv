#!/bin/sh
# This file is part of ke-recv
#
# Copyright (C) 2008 Nokia Corporation. All rights reserved.
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

if [ "x$1" != "x/dev/mmcblk1" -a "x$1" != "x/dev/mmcblk0" ]; then
  echo "Usage: $0 <device name of internal memory card>"
  exit 1
fi

sfdisk -D -uM $1 << EOF
,512,S
,2048,L
,,b
EOF

echo "$0: done."
