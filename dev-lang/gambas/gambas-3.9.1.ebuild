# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
inherit rindeal

inherit flag-o-matic
inherit autotools eutils xdg

DESCRIPTION="Gambas is a free development environment based on a Basic interpreter"
HOMEPAGE="http://gambas.sourceforge.net/en/main.html"
LICENSE="GPL-2"

SLOT="3"
PN_SLOTTED="${PN}${SLOT}"
MY_P="${PN_SLOTTED}-${PV}"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.bz2"

KEYWORDS="~amd64"
IUSE_A=(
	'+curl' '+net' '+qt4' '+x11'
	'bzip2' 'cairo' 'crypt' 'dbus' 'examples' 'gmp' 'gnome' 'gsl' 'gstreamer' 'gtk2' 'gtk3'
	'httpd' 'image-imlib' 'image-io' 'jit' 'libxml' 'mime' 'mysql' 'ncurses' 'odbc' 'openal'
	'opengl' 'openssl' 'pcre' 'pdf' 'pop3' 'postgres' 'qt4-opengl' 'qt4-webkit' 'qt5' 'sdl'
	'sdl-sound' 'sdl2' 'sqlite' 'v4l' 'xml' 'zlib'
)

# gambas3 have the only one gui. it is based on qt4.
# these use flags (modules/plugins) require this qt4 gui to be present at the system to work properly:
# cairo gnome gstreamer gtk2 gtk3 imageimlib imageio opengl pdf sdl sdl2 v4l

REQUIRED_USE="
	cairo? ( qt4 x11 )
	gnome? ( qt4 x11 )
	gstreamer? ( qt4 x11 )
	gtk2? ( qt4 x11 )
	gtk3? ( qt4 x11 )
	image-imlib? ( qt4 x11 )
	image-io? ( qt4 x11 )
	net? (
		curl
		pop3? ( mime )
	)
	opengl? ( qt4 x11 )
	pdf? ( qt4 x11 )
	qt4? ( x11 )
	qt4-opengl? ( qt4 )
	qt4-webkit? ( qt4 )
	sdl? ( qt4 x11 )
	sdl-sound? ( sdl )
	sdl2? ( qt4 x11 )
	v4l? ( qt4 x11 )
"

RDEPEND="
	bzip2? ( app-arch/bzip2 )
	cairo? ( x11-libs/cairo )
	curl? ( net-misc/curl )
	dbus? ( sys-apps/dbus )
	gnome? ( gnome-base/gnome-keyring )
	gmp? ( dev-libs/gmp:* )
	gsl? ( sci-libs/gsl )
	gstreamer? ( media-libs/gst-plugins-base:0.10 media-libs/gstreamer:0.10 )
	gtk2? ( x11-libs/gtk+:2 )
	gtk3? ( x11-libs/gtk+:3 )
	jit? ( sys-devel/llvm )
	image-imlib? ( media-libs/imlib2 )
	image-io? ( dev-libs/glib:2 x11-libs/gdk-pixbuf )
	libxml? ( dev-libs/libxml2 )
	mime? ( dev-libs/gmime )
	mysql?  ( virtual/mysql )
	ncurses? ( sys-libs/ncurses:5 )
	odbc? ( dev-db/unixODBC )
	openal? ( media-libs/openal )
	opengl? ( media-libs/mesa )
	openssl? ( dev-libs/openssl:0 )
	pcre? ( dev-libs/libpcre )
	pdf? ( app-text/poppler:= )
	postgres? ( dev-db/postgresql:* )
	qt4? (
		dev-qt/qtcore:4[qt3support]
		dev-qt/qtgui:4[qt3support]
		dev-qt/qtsvg:4
	)
	qt4-opengl? ( dev-qt/qtopengl:4[qt3support] )
	qt4-webkit? ( dev-qt/qtwebkit:4 )
	qt5? (
		>=dev-qt/qtcore-5.4.0:5
		>=dev-qt/qtopengl-5.4.0:5
		>=dev-qt/qtwebkit-5.4.0:5
	)
	sdl? (
		media-libs/libsdl[opengl]
		media-libs/sdl-image
		media-libs/sdl-ttf
	)
	sdl-sound? ( media-libs/sdl-mixer )
	sdl2? (
		media-libs/libsdl2
		media-libs/sdl2-image
		media-libs/sdl2-mixer
	)
	v4l? ( virtual/jpeg:0 media-libs/libpng:* )
	x11? ( x11-libs/libX11 x11-libs/libXtst )
	xml? ( dev-libs/libxml2 dev-libs/libxslt )
	zlib? ( sys-libs/zlib )
"
DEPEND="${RDEPEND}
	virtual/libintl
	virtual/pkgconfig
"

RESTRICT="mirror"

inherit arrays

S="${WORKDIR}/${MY_P}"

autocrap_cleanup() {
	sed -e "/^\(AC\|GB\)_CONFIG_SUBDIRS(${1}[,)]/d" \
		-i -- "${S}/configure.ac" || die
	sed -e "/^ \(@${1}_dir@\|${1}\)/d" \
		-i -- "${S}/Makefile.am" || die
}

src_prepare() {
	xdg_src_prepare

	# do not call xdg-* utils
	find . -name "Makefile.am" | xargs \
		sed -r -e 's|^[ \t]*xdg-.*\\|\\|' -i --
	assert

	local sedargs=(
		# respect C(XX)FLAGS
		-e '/C(XX)?FLAGS=""/d'
		-e '/CX*FLAGS[_A-Z]*=/ s:(-O[a-z0-9]*|-g[a-z0-9]*|-fno-omit-[a-z-]*)::g'
	)
	sed -r "${sedargs[@]}" -i -- acinclude.m4 || die

	# deprecated
	autocrap_cleanup sqlite2

	use_if_iuse bzip2 || autocrap_cleanup bzlib2
	use_if_iuse cairo || autocrap_cleanup cairo
	use_if_iuse crypt || autocrap_cleanup crypt
	use_if_iuse curl || autocrap_cleanup curl
	use_if_iuse dbus || autocrap_cleanup dbus
	use_if_iuse examples || autocrap_cleanup examples
	use_if_iuse gsl || autocrap_cleanup gsl
	use_if_iuse gmp || autocrap_cleanup gmp
	use_if_iuse gnome || autocrap_cleanup keyring
	use_if_iuse gstreamer || autocrap_cleanup media
	use_if_iuse gtk2 || autocrap_cleanup gtk
	use_if_iuse gtk3 || autocrap_cleanup gtk3
	use_if_iuse httpd || autocrap_cleanup httpd
	use_if_iuse image-imlib || autocrap_cleanup imageimlib
	use_if_iuse image-io || autocrap_cleanup imageio
	use_if_iuse jit || autocrap_cleanup jit
	use_if_iuse libxml || autocrap_cleanup libxml
	use_if_iuse mime || autocrap_cleanup mime
	use_if_iuse mysql || autocrap_cleanup mysql
	use_if_iuse ncurses || autocrap_cleanup ncurses
	use_if_iuse net || autocrap_cleanup net
	use_if_iuse odbc || autocrap_cleanup odbc
	use_if_iuse openal || autocrap_cleanup openal
	use_if_iuse opengl || autocrap_cleanup opengl
	use_if_iuse openssl || autocrap_cleanup openssl
	use_if_iuse pcre || autocrap_cleanup pcre
	use_if_iuse pdf || autocrap_cleanup pdf
	use_if_iuse postgres || autocrap_cleanup postgresql
	use_if_iuse qt4 || autocrap_cleanup qt4
	use_if_iuse qt5 || autocrap_cleanup qt5
	use_if_iuse sdl || autocrap_cleanup sdl
	use_if_iuse sdl-sound || autocrap_cleanup sdlsound
	use_if_iuse sdl2 || autocrap_cleanup sdl2
	use_if_iuse sqlite || autocrap_cleanup sqlite
	use_if_iuse v4l || autocrap_cleanup v4l
	use_if_iuse x11 || autocrap_cleanup x11
	use_if_iuse xml || autocrap_cleanup xml
	use_if_iuse zlib || autocrap_cleanup zlib

	eautoreconf
}

src_configure() {
	append-cxxflags -std=gnu++11

	local args=()

	if use qt4 ; then
		pushd "${S}/gb.qt4" >/dev/null || die
		args=(
			$(use_enable qt4-opengl qtopengl)
			$(use_enable qt4-webkit qtwebkit)
		)
		econf "${args[@]}"
		popd >/dev/null || die
	fi

	args=(
		$(use_enable bzip2 bzlib2)
		$(use_enable cairo)
		$(use_enable crypt)
		$(use_enable curl)
		$(use_enable dbus)
		$(use_enable examples)
		$(use_enable gmp)
		$(use_enable gnome keyring)
		$(use_enable gsl)
		$(use_enable gstreamer media)
		$(use_enable gtk2)
		$(use_enable gtk3)
		$(use_enable httpd)
		$(use_enable image-imlib imageimlib)
		$(use_enable image-io imageio)
		$(use_enable jit)
		$(use_enable libxml)
		$(use_enable mime)
		$(use_enable mysql)
		$(use_enable ncurses)
		$(use_enable net)
		$(use_enable odbc)
		$(use_enable openal)
		$(use_enable opengl)
		$(use_enable openssl)
		$(use_enable pcre)
		$(use_enable pdf)
		$(use_enable postgres postgresql)
		$(use_enable qt4)
		$(use_enable qt5)
		$(use_enable sdl)
		$(use_enable sdl-sound sdlsound)
		$(use_enable sqlite sqlite3)
		$(use_enable v4l)
		$(use_enable x11)
		$(use_enable xml)
		$(use_enable zlib)
	)
	econf "${args[@]}"
}

src_install() {
	emake -j1 DESTDIR="${D}" install

	einstalldocs

	if use net ; then
		newdoc gb.net/src/doc/README gb.net-README
		newdoc gb.net/src/doc/changes.txt gb.net-ChangeLog
	fi

	use pcre && newdoc gb.pcre/src/README gb.pcre-README

	if use qt4 ; then
		doicon -s scalable "${S}/app/desktop/${PN_SLOTTED}.svg"
		domenu "${S}/app/desktop/${PN_SLOTTED}.desktop"

		doicon -s 64 -c mimetypes \
			"${S}/app/mime/application-x-gambasscript.png" \
			"${S}/app/mime/application-x-gambasserverpage.png" \
			"${S}/main/mime/application-x-${PN_SLOTTED}.png"

		insinto /usr/share/mime/application
		doins "${S}/app/mime/application-x-gambasscript.xml" \
			"${S}/app/mime/application-x-gambasserverpage.xml" \
			"${S}/main/mime/application-x-${PN_SLOTTED}.xml"
	fi

	prune_libtool_files --modules
}
