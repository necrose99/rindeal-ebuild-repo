# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5


PYTHON_COMPAT=( python3_{3,4})

inherit distutils-r1 python-r1


DESCRIPTION="C++ 98/11/14 manual pages for Linux, with source from cplusplus.com and cppreference.com."
HOMEPAGE="https://github.com/aitjcize/cppman"
SRC_URI="https://pypi.python.org/packages/source/c/${PN}/${P}.tar.gz"
LICENSE="GPL-3"

RESTRICT="mirror"

SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
    sys-apps/groff
    >=dev-python/beautifulsoup-4.0.0
"