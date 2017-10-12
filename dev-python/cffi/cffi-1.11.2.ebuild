# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="bitbucket"
GH_REF="v${PV}"

# DO NOT ADD pypy to PYTHON_COMPAT
# pypy bundles a modified version of cffi. Use python_gen_cond_dep instead.
PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit git-hosting
inherit distutils-r1

DESCRIPTION="Foreign Function Interface for Python calling C code"
HOMEPAGE="https://cffi.readthedocs.org/ ${GH_HOMEPAGE} https://pypi.python.org/pypi/cffi"
LICENSE="MIT"

SLOT="0/${PV}"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="doc test"

CDEPEND="
	virtual/libffi
	dev-python/pycparser[${PYTHON_USEDEP}]"
DEPEND="${CDEPEND}
	virtual/pkgconfig
	doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )
	test? (	dev-python/pytest[${PYTHON_USEDEP}] )"
RDEPEND="${CDEPEND}"

# Avoid race on _configtest.c (distutils/command/config.py:_gen_temp_sourcefile)
DISTUTILS_IN_SOURCE_BUILD=1

python_compile_all() {
	use doc && emake -C doc html
}

python_test() {
	einfo "$PYTHONPATH"
	$PYTHON -c "import _cffi_backend as backend" || die
	PYTHONPATH="${PYTHONPATH}" \
	py.test -x -v \
		--ignore testing/test_zintegration.py \
		--ignore testing/embedding \
		c/ testing/ \
		|| die "Testing failed with ${EPYTHON}"
}

python_install_all() {
	use doc && local HTML_DOCS=( doc/build/html/. )
	distutils-r1_python_install_all
}