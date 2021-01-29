# Copyright (c) 2019 The FydeOS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="Chrome OS BSP virtual package"
HOMEPAGE="http://src.chromium.org"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="-* amd64 x86"

RDEPEND="app-emulation/open-vm-tools
         chromeos-base/device-appid
         chromeos-base/auto-expand-partition"
